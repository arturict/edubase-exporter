#!/usr/bin/env python3
"""
Edubase to PDF Exporter - Ubuntu/Linux CLI
Screenshot capture and PDF builder for Edubase with OCR
"""
import os
import sys
import time
import tempfile
import subprocess
from pathlib import Path
from typing import List, Optional

import click
from rich.console import Console
from rich.progress import (
    Progress,
    SpinnerColumn,
    BarColumn,
    TaskProgressColumn,
    TextColumn,
    TimeRemainingColumn,
    DownloadColumn,
)
from rich.panel import Panel
from rich.prompt import Confirm, Prompt
from rich.table import Table
from rich import box

from PIL import Image
import img2pdf
import pikepdf
from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout

# Initialize Rich console
console = Console()


# ---------- Utils ----------

def natural_key(s: str):
    import re
    return [int(t) if t.isdigit() else t.lower() for t in re.split(r'(\d+)', s)]


def list_images(input_dir: Path) -> List[Path]:
    exts = {'.png', '.jpg', '.jpeg', '.tif', '.tiff', '.webp'}
    files = [f for f in input_dir.iterdir() if f.suffix.lower() in exts and f.is_file()]
    files.sort(key=lambda p: natural_key(p.name))
    return files


def ensure_dir(p: Path):
    p.mkdir(parents=True, exist_ok=True)


def get_system_info():
    """Get system information"""
    import platform
    return {
        'os': platform.system(),
        'python_version': platform.python_version(),
    }


def format_size(bytes_size: int) -> str:
    """Format bytes to human-readable size"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if bytes_size < 1024:
            return f"{bytes_size:.1f} {unit}"
        bytes_size /= 1024
    return f"{bytes_size:.1f} TB"


def auto_crop_image(img: Image.Image, threshold: int, margin_px: int) -> Image.Image:
    g = img.convert('L')
    mask = g.point(lambda x: 0 if x > threshold else 255, mode='1')
    bbox = mask.getbbox()
    if not bbox:
        return img
    left, top, right, bottom = bbox
    left = max(left - margin_px, 0)
    top = max(top - margin_px, 0)
    right = min(right + margin_px, img.width)
    bottom = min(bottom + margin_px, img.height)
    return img.crop((left, top, right, bottom))


# ---------- Capture Phase ----------

def capture_pages(
    book_url: str,
    total_pages: int,
    out_dir: Path,
    user_data_dir: Path,
    start_index: int,
    per_page_delay_ms: int,
    fullpage: bool,
    crop: bool,
    crop_threshold: int,
    crop_margin: int,
) -> None:
    """Capture pages on Ubuntu with Playwright"""
    
    ensure_dir(out_dir)
    
    # Extract book ID
    import re
    match = re.search(r'#doc/(\d+)', book_url)
    book_id = match.group(1) if match else None
    
    # Welcome panel
    console.print()
    welcome = Panel.fit(
        f"[bold cyan]📸 Screenshot Capture[/bold cyan]\n\n"
        f"Book: [yellow]{book_url}[/yellow]\n"
        f"Pages: [green]{total_pages}[/green]\n"
        f"Output: [blue]{out_dir}[/blue]",
        border_style="cyan",
        title="[bold]Edubase Exporter[/bold]",
        title_align="left",
    )
    console.print(welcome)
    console.print()
    
    # Check for existing screenshots
    existing = list(out_dir.glob("page_*.png"))
    if existing and start_index == 1:
        console.print(f"[yellow]⚠️  Found {len(existing)} existing screenshots[/yellow]")
        console.print()
        
        choice = Prompt.ask(
            "What would you like to do?",
            choices=["restart", "resume", "cancel"],
            default="resume"
        )
        
        if choice == "cancel":
            console.print("[red]Cancelled.[/red]")
            return
        elif choice == "restart":
            console.print("[yellow]🗑️  Removing old screenshots...[/yellow]")
            for f in existing:
                f.unlink()
            console.print("[green]✓ Ready for fresh capture[/green]")
        else:
            console.print("[blue]ℹ️  Resuming from last position[/blue]")
        console.print()
    
    # Instructions
    if start_index == 1:
        instructions = Table(show_header=False, box=box.ROUNDED, border_style="blue")
        instructions.add_column(justify="left")
        instructions.add_row("[bold cyan]1.[/bold cyan] Browser will open automatically")
        instructions.add_row("[bold cyan]2.[/bold cyan] [bold]Log in[/bold] to Edubase (first time only)")
        instructions.add_row("[bold cyan]3.[/bold cyan] [bold]Set viewer:[/bold]")
        instructions.add_row("   • Zoom: [yellow]100-120%[/yellow]")
        instructions.add_row("   • View: [yellow]Fit to page[/yellow]")
        instructions.add_row("   • Close sidebar/menus")
        instructions.add_row("[bold cyan]4.[/bold cyan] Press [bold green]Enter[/bold green] to start")
        
        console.print(Panel(instructions, title="[bold]Setup Instructions[/bold]", border_style="blue"))
        console.print()
        
        console.input("[bold green]Press Enter when ready...[/bold green] ")
        console.print()
    
    # Start browser
    with sync_playwright() as p:
        console.print("[green]✓[/green] Browser started")
        
        # Use Firefox with separate profile directory
        firefox_profile_dir = Path.home() / '.edubase_browser_firefox'
        viewport_config = {'width': 1920, 'height': 1080}
        
        context = p.firefox.launch_persistent_context(
            user_data_dir=str(firefox_profile_dir),
            headless=False,
            viewport=viewport_config,
        )
        
        context.set_default_timeout(30000)
        context.set_default_navigation_timeout(30000)
        
        page = context.pages[0] if context.pages else context.new_page()
        
        # Maximize window for full visibility
        try:
            page.evaluate("""() => {
                window.moveTo(0, 0);
                window.resizeTo(screen.availWidth, screen.availHeight);
            }""")
        except Exception:
            # Fallback: Use init script for next page loads
            try:
                page.context.add_init_script("""
                    window.moveTo(0, 0);
                    window.resizeTo(screen.availWidth, screen.availHeight);
                """)
            except Exception:
                pass  # Window maximization is non-critical
        
        # Navigate to book
        console.print(f"[blue]🔗[/blue] Opening: [cyan]{book_url}[/cyan]")
        try:
            page.goto(book_url, wait_until="domcontentloaded", timeout=30000)
            page.wait_for_load_state("networkidle", timeout=10000)
        except PWTimeout:
            console.print("[yellow]⚠️  Page loading slowly, continuing anyway...[/yellow]")
        
        # Wait a bit for Edubase to fully load - MINIMAL intervention
        page.wait_for_load_state("networkidle", timeout=5000)
        time.sleep(2.0)  # Give Edubase time to render
        
        # Give user time to prepare
        if start_index == 1:
            console.print()
            console.print(Panel(
                "[yellow]⚠️  IMPORTANT[/yellow]\n\n"
                "1. Log in if needed\n"
                "2. Adjust viewer settings\n"
                "3. When ready, press Enter in terminal",
                border_style="yellow"
            ))
            console.input("\n[bold green]Press Enter to start capture...[/bold green] ")
            console.print()
        
        # Start capture with progress bar
        console.print("[bold blue]📸 Starting capture...[/bold blue]")
        console.print()
        
        captured_count = 0
        skipped_count = 0
        failed_pages = []
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[bold blue]{task.description}"),
            BarColumn(),
            TaskProgressColumn(),
            TimeRemainingColumn(),
            console=console,
        ) as progress:
            
            task = progress.add_task(
                f"Capturing pages {start_index}-{total_pages}",
                total=total_pages - start_index + 1
            )
            
            for i in range(start_index, total_pages + 1):
                filename = out_dir / f"page_{i:04d}.png"
                
                # Skip existing
                if filename.exists():
                    skipped_count += 1
                    progress.advance(task)
                    continue
                
                # Navigate to page
                if book_id and i > start_index:
                    page_url = f"https://app.edubase.ch/#doc/{book_id}/{i}"
                    try:
                        response = page.goto(page_url, wait_until="domcontentloaded", timeout=15000)
                        # Check if response indicates an error (4xx, 5xx)
                        if response and response.status >= 400:
                            console.log(f"[yellow]Page {i} returned status {response.status}[/yellow]")
                        page.wait_for_load_state("networkidle", timeout=3000)
                    except PWTimeout:
                        pass  # Page loaded but networkidle timeout - usually fine
                    except Exception as e:
                        console.log(f"[red]Page {i} navigation failed: {e}[/red]")
                        failed_pages.append(i)
                        progress.advance(task)
                        continue
                
                # Wait for page to render - NO manipulation
                page.wait_for_load_state("networkidle", timeout=3000)
                time.sleep(1.5)  # Give Edubase time to render the PDF
                
                # Capture screenshot
                try:
                    page.screenshot(path=str(filename), full_page=True, type="png")
                    
                    # Optional crop
                    if crop:
                        with Image.open(filename) as im:
                            if im.mode in ('RGBA', 'P'):
                                im = im.convert('RGB')
                            im = auto_crop_image(im, threshold=crop_threshold, margin_px=crop_margin)
                            im.save(filename, format="PNG", optimize=True)
                    
                    captured_count += 1
                    
                except Exception as e:
                    console.log(f"[red]Page {i} screenshot failed: {e}[/red]")
                    failed_pages.append(i)
                
                progress.advance(task)
                
                if i < total_pages:
                    time.sleep(per_page_delay_ms / 1000.0)
        
        context.close()
        
        # Summary
        console.print()
        summary = Table(show_header=False, box=box.ROUNDED, border_style="green")
        summary.add_column("Metric", style="cyan")
        summary.add_column("Value", style="green")
        summary.add_row("✓ Captured", str(captured_count))
        if skipped_count > 0:
            summary.add_row("⏭️  Skipped", f"{skipped_count} (already existed)")
        if failed_pages:
            summary.add_row("❌ Failed", f"{len(failed_pages)}: {failed_pages}")
        
        total_files = len(list(out_dir.glob("page_*.png")))
        summary.add_row("📁 Total Files", str(total_files))
        
        console.print(Panel(summary, title="[bold green]✓ Capture Complete[/bold green]", border_style="green"))
        
        if failed_pages:
            console.print(f"\n[yellow]💡 Tip: Restart with --start-index {failed_pages[0]} to retry failed pages[/yellow]")
        
        console.print()
        console.print("[bold cyan]➜ Next:[/bold cyan] Run [yellow]python edubase_cli.py build[/yellow] to create PDF")
        console.print()


# ---------- Build Phase ----------

def build_pdf_from_images(images: List[Path], out_pdf: Path, dpi: Optional[int]) -> None:
    layout = None
    if dpi:
        layout = (dpi, dpi)
    with open(out_pdf, "wb") as f:
        f.write(img2pdf.convert([str(p) for p in images], dpi=layout))


def run_ocr(input_pdf: Path, output_pdf: Path, lang: str, jobs: int, optimize: int) -> None:
    """Run OCR on Ubuntu with ocrmypdf"""
    cmd = [
        "ocrmypdf",
        "--language", lang,
        "--jobs", str(jobs),
        f"--optimize={optimize}",
        "--skip-text",
        "--deskew",
        str(input_pdf),
        str(output_pdf)
    ]
    
    subprocess.run(cmd, check=True)


def set_metadata(pdf_path: Path, title: Optional[str], author: Optional[str],
                 subject: Optional[str], keywords: Optional[List[str]]) -> None:
    with pikepdf.open(pdf_path, allow_overwriting_input=True) as pdf:
        info = pdf.docinfo
        if title:
            info["/Title"] = title
        if author:
            info["/Author"] = author
        if subject:
            info["/Subject"] = subject
        if keywords and len(keywords) > 0:
            info["/Keywords"] = ", ".join(keywords)
        info["/Producer"] = "edubase2pdf (Playwright + img2pdf + ocrmypdf)"
        pdf.save(pdf_path)


def build_pipeline(
    input_dir: Path,
    output_pdf: Path,
    lang: str,
    jobs: int,
    optimize: int,
    dpi: Optional[int],
    jpeg_quality: int,
    crop: bool,
    crop_threshold: int,
    crop_margin: int,
    title: Optional[str],
    author: Optional[str],
    subject: Optional[str],
    keywords: Optional[str],
) -> None:
    """Build PDF with OCR on Ubuntu/Linux"""
    
    sys_info = get_system_info()
    
    # Welcome
    console.print()
    welcome = Panel.fit(
        f"[bold cyan]📚 PDF Builder with OCR[/bold cyan]\n\n"
        f"Input: [yellow]{input_dir}[/yellow]\n"
        f"Output: [green]{output_pdf}[/green]\n"
        f"Language: [blue]{lang}[/blue]\n"
        f"Platform: [magenta]{sys_info['os']}[/magenta]",
        border_style="cyan",
        title="[bold]Edubase Exporter[/bold]",
        title_align="left",
    )
    console.print(welcome)
    console.print()
    
    # Check for images
    images = list_images(input_dir)
    if not images:
        console.print(Panel(
            "[red]❌ No images found![/red]\n\n"
            f"Directory: {input_dir}\n\n"
            "Please run capture first:\n"
            "[yellow]python edubase_cli.py capture --help[/yellow]",
            border_style="red"
        ))
        sys.exit(1)
    
    console.print(f"[green]✓[/green] Found [cyan]{len(images)}[/cyan] images")
    console.print(f"   First: [yellow]{images[0].name}[/yellow]")
    console.print(f"   Last: [yellow]{images[-1].name}[/yellow]")
    console.print()
    
    # Check if output exists
    if output_pdf.exists():
        if not Confirm.ask(f"[yellow]Output file exists. Overwrite?[/yellow]", default=False):
            console.print("[red]Cancelled.[/red]")
            sys.exit(0)
        console.print()
    
    keywords_list = [k.strip() for k in keywords.split(",")] if keywords else None
    ensure_dir(output_pdf.parent)
    
    tmpdir = Path(tempfile.mkdtemp())
    processed_dir = tmpdir / "processed"
    ensure_dir(processed_dir)
    processed = []
    
    # Step 1: Preprocess images
    console.print(Panel(
        "[bold cyan]Step 1/4:[/bold cyan] Image Preprocessing\n\n"
        f"Actions: {'Crop + ' if crop else ''}JPEG conversion (quality {jpeg_quality})",
        border_style="cyan"
    ))
    console.print()
    
    with Progress(
        SpinnerColumn(),
        TextColumn("[bold blue]{task.description}"),
        BarColumn(),
        TaskProgressColumn(),
        TimeRemainingColumn(),
        console=console,
    ) as progress:
        
        task = progress.add_task("Processing images", total=len(images))
        
        for img_path in images:
            with Image.open(img_path) as im:
                if crop:
                    im = auto_crop_image(im, threshold=crop_threshold, margin_px=crop_margin)
                if im.mode in ('RGBA', 'P'):
                    im = im.convert('RGB')
                out_file = processed_dir / (img_path.stem + ".jpg")
                im.save(out_file, format="JPEG", quality=jpeg_quality, optimize=True)
                processed.append(out_file)
            progress.advance(task)
    
    console.print("[green]✓[/green] Images preprocessed")
    console.print()
    
    # Step 2: Create raw PDF
    console.print(Panel(
        "[bold cyan]Step 2/4:[/bold cyan] Creating Raw PDF",
        border_style="cyan"
    ))
    console.print()
    
    raw_pdf = tmpdir / "raw.pdf"
    with console.status("[bold blue]Building PDF from images...[/bold blue]"):
        build_pdf_from_images(processed, raw_pdf, dpi=dpi)
    
    pdf_size = raw_pdf.stat().st_size
    console.print(f"[green]✓[/green] Raw PDF created: [cyan]{format_size(pdf_size)}[/cyan]")
    console.print()
    
    # Step 3: OCR
    console.print(Panel(
        f"[bold cyan]Step 3/4:[/bold cyan] OCR Text Recognition\n\n"
        f"Language: [blue]{lang}[/blue]\n"
        f"Jobs: [yellow]{jobs}[/yellow]\n"
        f"Estimated time: [yellow]~{len(images)//6} minutes[/yellow]\n\n"
        "[dim]This may take several minutes. Please wait...[/dim]",
        border_style="cyan"
    ))
    console.print()
    
    ocr_pdf = tmpdir / "ocr.pdf"
    
    with console.status("[bold yellow]Running OCR (this takes time)...[/bold yellow]", spinner="dots"):
        try:
            run_ocr(
                input_pdf=raw_pdf,
                output_pdf=ocr_pdf,
                lang=lang,
                jobs=jobs,
                optimize=optimize
            )
        except subprocess.CalledProcessError as e:
            console.print(f"[red]❌ OCR failed: {e}[/red]")
            console.print()
            console.print("[yellow]Make sure ocrmypdf is installed:[/yellow]")
            console.print("  Ubuntu/Linux: sudo apt install ocrmypdf tesseract-ocr-deu")
            sys.exit(1)
    
    console.print("[green]✓[/green] OCR completed")
    console.print()
    
    # Step 4: Finalize
    console.print(Panel(
        "[bold cyan]Step 4/4:[/bold cyan] Finalizing PDF",
        border_style="cyan"
    ))
    console.print()
    
    with console.status("[bold blue]Setting metadata and saving...[/bold blue]"):
        ocr_pdf.replace(output_pdf)
        set_metadata(output_pdf, title, author, subject, keywords_list)
    
    final_size = output_pdf.stat().st_size
    console.print("[green]✓[/green] Metadata set")
    console.print("[green]✓[/green] PDF saved")
    console.print()
    
    # Success summary
    result = Table(show_header=False, box=box.ROUNDED, border_style="green")
    result.add_column("Property", style="cyan")
    result.add_column("Value", style="green")
    result.add_row("📄 File", str(output_pdf))
    result.add_row("💾 Size", format_size(final_size))
    result.add_row("📊 Pages", str(len(images)))
    result.add_row("🔤 OCR", f"{lang} (searchable)")
    
    console.print(Panel(result, title="[bold green]🎉 PDF Successfully Created![/bold green]", border_style="green"))
    console.print()
    
    # Open suggestion
    open_cmd = f"xdg-open {output_pdf}"
    console.print(f"[bold cyan]Open PDF:[/bold cyan] [yellow]{open_cmd}[/yellow]")
    console.print()


# ---------- CLI Commands ----------

@click.group()
@click.version_option(version="1.0.0", prog_name="edubase-exporter")
def cli():
    """
    Edubase to PDF Exporter - Ubuntu/Linux tool for creating searchable PDFs
    """
    pass


@cli.command()
@click.option('--book-url', required=True, help='Book viewer URL (e.g., https://app.edubase.ch/#doc/60505/1)')
@click.option('--pages', type=int, required=True, help='Total number of pages')
@click.option('--out-dir', type=click.Path(), default='./input_pages', help='Output directory for screenshots')
@click.option('--user-data-dir', type=click.Path(), default=None, help='Browser profile directory (default: ~/.edubase_browser)')
@click.option('--start-index', type=int, default=1, help='Start page number')
@click.option('--delay-ms', type=int, default=1500, help='Delay between pages (milliseconds)')
@click.option('--fullpage', is_flag=True, default=True, help='Use fullpage screenshots')
@click.option('--crop/--no-crop', default=True, help='Auto-crop white margins')
@click.option('--crop-threshold', type=int, default=248, help='Crop threshold (200-254)')
@click.option('--crop-margin', type=int, default=10, help='Crop margin (pixels)')
def capture(book_url, pages, out_dir, user_data_dir, start_index, delay_ms, fullpage, crop, crop_threshold, crop_margin):
    """
    Capture screenshots from Edubase viewer.
    
    Example:
        python edubase_cli.py capture --book-url "https://app.edubase.ch/#doc/60505/1" --pages 396
    """
    out_path = Path(out_dir).expanduser().resolve()
    
    if user_data_dir:
        user_data_path = Path(user_data_dir).expanduser().resolve()
    else:
        # Default location in user home
        user_data_path = Path.home() / '.edubase_browser'
    
    capture_pages(
        book_url=book_url,
        total_pages=pages,
        out_dir=out_path,
        user_data_dir=user_data_path,
        start_index=start_index,
        per_page_delay_ms=delay_ms,
        fullpage=fullpage,
        crop=crop,
        crop_threshold=crop_threshold,
        crop_margin=crop_margin,
    )


@cli.command()
@click.option('--input', 'input_dir', type=click.Path(exists=True), default='./input_pages', help='Input images directory')
@click.option('--output', type=click.Path(), default='./output/book.pdf', help='Output PDF path')
@click.option('--lang', default='deu', help='OCR language (e.g., deu, eng, deu+eng)')
@click.option('--jobs', type=int, default=6, help='Parallel OCR jobs')
@click.option('--optimize', type=int, default=2, help='Optimization level (0-3)')
@click.option('--dpi', type=int, default=300, help='DPI for PDF')
@click.option('--jpeg-quality', type=int, default=92, help='JPEG quality (80-95)')
@click.option('--crop/--no-crop', default=True, help='Auto-crop images')
@click.option('--crop-threshold', type=int, default=248, help='Crop threshold')
@click.option('--crop-margin', type=int, default=10, help='Crop margin')
@click.option('--title', default=None, help='PDF title metadata')
@click.option('--author', default=None, help='PDF author metadata')
@click.option('--subject', default=None, help='PDF subject metadata')
@click.option('--keywords', default=None, help='Comma-separated keywords')
def build(input_dir, output, lang, jobs, optimize, dpi, jpeg_quality, crop, crop_threshold, crop_margin, title, author, subject, keywords):
    """
    Build searchable PDF from screenshots with OCR.
    
    Example:
        python edubase_cli.py build --input ./input_pages --output ./output/book.pdf --title "My Book"
    """
    input_path = Path(input_dir).expanduser().resolve()
    output_path = Path(output).expanduser().resolve()
    
    build_pipeline(
        input_dir=input_path,
        output_pdf=output_path,
        lang=lang,
        jobs=jobs,
        optimize=optimize,
        dpi=dpi,
        jpeg_quality=jpeg_quality,
        crop=crop,
        crop_threshold=crop_threshold,
        crop_margin=crop_margin,
        title=title,
        author=author,
        subject=subject,
        keywords=keywords,
    )


@cli.command()
def check():
    """Check system requirements and dependencies."""
    
    console.print()
    console.print(Panel("[bold cyan]System Check[/bold cyan]", border_style="cyan"))
    console.print()
    
    sys_info = get_system_info()
    
    # System info
    info = Table(show_header=False, box=box.SIMPLE)
    info.add_column("Property", style="cyan")
    info.add_column("Value")
    info.add_row("Operating System", sys_info['os'])
    info.add_row("Python Version", sys_info['python_version'])
    
    console.print(info)
    console.print()
    
    # Check dependencies
    deps = Table(title="Dependencies", box=box.ROUNDED)
    deps.add_column("Component", style="cyan")
    deps.add_column("Status")
    deps.add_column("Notes")
    
    # Python packages
    packages = ['playwright', 'PIL', 'img2pdf', 'pikepdf', 'click', 'rich']
    for pkg in packages:
        try:
            __import__(pkg if pkg != 'PIL' else 'PIL')
            deps.add_row(f"Python: {pkg}", "[green]✓ Installed[/green]", "")
        except ImportError:
            deps.add_row(f"Python: {pkg}", "[red]✗ Missing[/red]", "pip install -r requirements.txt")
    
    # System tools
    tools = [
        ('ocrmypdf', 'OCR processing'),
        ('tesseract', 'Text recognition'),
    ]
    
    for tool, desc in tools:
        try:
            result = subprocess.run([tool, '--version'], capture_output=True, timeout=2)
            if result.returncode == 0:
                deps.add_row(f"Tool: {tool}", "[green]✓ Installed[/green]", desc)
            else:
                deps.add_row(f"Tool: {tool}", "[yellow]⚠ Issue[/yellow]", desc)
        except (subprocess.TimeoutExpired, FileNotFoundError):
            deps.add_row(f"Tool: {tool}", "[red]✗ Missing[/red]", desc)
    
    console.print(deps)
    console.print()
    
    # Installation hints
    console.print("[cyan]Install missing tools on Ubuntu:[/cyan]")
    console.print("  [yellow]sudo apt install ocrmypdf tesseract-ocr-deu[/yellow]")
    
    console.print()


if __name__ == '__main__':
    cli()
