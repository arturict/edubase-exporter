#!/usr/bin/env python3
import argparse
import os
import re
import sys
import time
import tempfile
from pathlib import Path
from typing import List, Optional

from PIL import Image
import img2pdf
from tqdm import tqdm
import pikepdf

from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout


# ---------- Utils ----------

def natural_key(s: str):
    return [int(t) if t.isdigit() else t.lower() for t in re.split(r'(\d+)', s)]


def list_images(input_dir: Path) -> List[Path]:
    exts = {'.png', '.jpg', '.jpeg', '.tif', '.tiff', '.webp'}
    files = [f for f in input_dir.iterdir() if f.suffix.lower() in exts and f.is_file()]
    files.sort(key=lambda p: natural_key(p.name))
    return files


def ensure_dir(p: Path):
    p.mkdir(parents=True, exist_ok=True)


# Auto-crop white margins (simple heuristic)
def auto_crop_image(img: Image.Image, threshold: int, margin_px: int) -> Image.Image:
    g = img.convert('L')
    # Pixels > threshold considered white background
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


# ---------- Phase A: Capture ----------

def capture_pages(
    book_url: str,
    total_pages: int,
    out_dir: Path,
    user_data_dir: Path,
    viewer_selector: Optional[str],
    start_index: int,
    per_page_delay_ms: int,
    fullpage: bool,
    crop: bool,
    crop_threshold: int,
    crop_margin: int,
    click_next_selector: Optional[str],
    advance_with_keys: bool,
) -> None:
    """
    Capture pages from an already accessible viewer.
    Uses direct URL navigation (e.g., /#doc/60505/23 for page 23) if possible.
    """
    ensure_dir(out_dir)
    
    # Extract book ID from URL for direct page navigation
    book_id = None
    import re
    match = re.search(r'#doc/(\d+)', book_url)
    if match:
        book_id = match.group(1)
        print(f"📖 Buch ID erkannt: {book_id}")
        print(f"🔗 Verwende direkte URL-Navigation für {total_pages} Seiten")
    else:
        print("⚠️  Konnte Buch ID nicht aus URL extrahieren, nutze Fallback-Methode")

    with sync_playwright() as p:
        print("\n🌐 Starte Browser (Chromium)...")
        
        # Browser args optimized for Ubuntu
        browser_args = [
            '--disable-blink-features=AutomationControlled',
            '--disable-dev-shm-usage',  # Avoid /dev/shm issues in containers
        ]
        
        # Viewport configuration - standard resolution for consistency
        viewport_config = {'width': 1920, 'height': 1080}
        
        # Device scale factor: 1.0 for standard display
        device_scale = 1.0
        
        # Persistent context for session reuse
        context = p.chromium.launch_persistent_context(
            user_data_dir=str(user_data_dir),
            headless=False,
            viewport=viewport_config,
            device_scale_factor=device_scale,
            args=browser_args,
            ignore_default_args=['--enable-automation'],  # Hide automation indicators
        )
        
        # Set default timeouts
        context.set_default_timeout(30000)  # 30s default timeout
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

        print(f"🔗 Öffne: {book_url}")
        try:
            page.goto(book_url, wait_until="domcontentloaded", timeout=30000)
            page.wait_for_load_state("networkidle", timeout=10000)
        except PWTimeout:
            print("⚠️  Seite lädt langsam, fahre trotzdem fort...")
        
        # Apply rendering stabilization to first page load too
        try:
            page.evaluate("""() => {
                const viewer = document.querySelector('[data-testid="pdfViewer"], .pdfViewer, iframe');
                if (viewer) {
                    viewer.scrollIntoView({ behavior: 'auto', block: 'center' });
                }
                window.scrollTo({ left: 0, top: 0, behavior: 'auto' });
            }""")
        except Exception:
            pass
        
        page.wait_for_load_state("networkidle", timeout=2000)
        time.sleep(0.5)  # Brief stabilization for initial load

        # Give user time to log in or adjust viewer
        if start_index == 1:
            print("\n" + "="*70)
            print("⚠️  WICHTIG: Bereite den Viewer vor!")
            print("="*70)
            print("\n1. Falls nötig: Logge dich jetzt in Edubase ein")
            print("2. Stelle den Viewer ein:")
            print("   • Ansicht: 'Fit to width' oder 'Fit to page'")
            print("   • Zoom: 100-120% (gut lesbar)")
            print("   • Keine Seitenleiste/Menüs sichtbar")
            print("\n3. Wenn alles bereit ist:")
            print("="*70)
            input("   Drücke Enter zum Starten...\n")

        # Best-effort wait for viewer element
        target_locator = None
        if viewer_selector:
            try:
                print(f"🔍 Suche Viewer-Element: {viewer_selector}")
                target_locator = page.locator(viewer_selector)
                target_locator.wait_for(timeout=5000, state='visible')
                print(f"✓ Viewer-Element gefunden")
            except PWTimeout:
                print("⚠️  Viewer-Element nicht gefunden, nutze Fullpage-Screenshots")
                target_locator = None

        print(f"\n📸 Starte Capture: Seite {start_index} bis {total_pages}")
        print("="*70)
        
        captured_count = 0
        skipped_count = 0
        failed_pages = []

        # Page loop with direct URL navigation
        for i in range(start_index, total_pages + 1):
            filename = out_dir / f"page_{i:04d}.png"
            
            # Skip if file already exists
            if filename.exists():
                print(f"  [Seite {i:>3}/{total_pages}] ⏭️  Bereits vorhanden, überspringe...")
                skipped_count += 1
                continue
            
            # Navigate directly to page URL if we have book_id
            if book_id and i > start_index:
                page_url = f"https://app.edubase.ch/#doc/{book_id}/{i}"
                try:
                    response = page.goto(page_url, wait_until="domcontentloaded", timeout=15000)
                    # Check if response indicates an error (4xx, 5xx)
                    if response and response.status >= 400:
                        print(f"  [Seite {i:>3}/{total_pages}] ⚠️  Status {response.status}")
                    # Wait for page to render (shorter than full delay)
                    page.wait_for_load_state("networkidle", timeout=3000)
                except PWTimeout:
                    # Page loaded but networkidle timeout - usually fine
                    pass
                except Exception as e:
                    print(f"  [Seite {i:>3}/{total_pages}] ⚠️  Navigation fehlgeschlagen: {e}")
                    failed_pages.append(i)
                    continue
            
            # Ensure content is centered and fully rendered
            try:
                page.evaluate("""() => {
                    // Center view on the book content
                    const viewer = document.querySelector('[data-testid="pdfViewer"], .pdfViewer, iframe');
                    if (viewer) {
                        viewer.scrollIntoView({ behavior: 'auto', block: 'center' });
                    }
                    // Also try to center viewport
                    window.scrollTo({ left: 0, top: 0, behavior: 'auto' });
                }""")
            except Exception:
                pass
            
            # Wait for all images to load and rendering to stabilize
            page.wait_for_load_state("networkidle", timeout=2000)
            time.sleep(1.0)  # Extra wait for rendering to stabilize
            
            # Verify content is visible before screenshot
            try:
                page.evaluate("() => { if (!document.body) throw new Error('Page not ready'); }")
            except Exception:
                pass  # Continue anyway - some pages may not have traditional body

            # Capture screenshot
            try:
                if target_locator and not fullpage:
                    target_locator.screenshot(path=str(filename), type="png")
                else:
                    page.screenshot(path=str(filename), full_page=True, type="png")
                
                # Optional crop
                if crop:
                    try:
                        with Image.open(filename) as im:
                            if im.mode in ('RGBA', 'P'):
                                im = im.convert('RGB')
                            im = auto_crop_image(im, threshold=crop_threshold, margin_px=crop_margin)
                            im.save(filename, format="PNG", optimize=True)
                    except Exception as e:
                        print(f"  [Seite {i:>3}/{total_pages}] ⚠️  Crop fehlgeschlagen: {e}")
                
                captured_count += 1
                file_size = filename.stat().st_size / 1024  # KB
                print(f"  [Seite {i:>3}/{total_pages}] ✓ Gespeichert ({file_size:.0f} KB)")
                
            except Exception as e:
                print(f"  [Seite {i:>3}/{total_pages}] ❌ Screenshot fehlgeschlagen: {e}")
                failed_pages.append(i)
                continue

            # Rate-limit between pages
            if i < total_pages:
                time.sleep(per_page_delay_ms / 1000.0)

        # Summary
        print("\n" + "="*70)
        print("📊 CAPTURE ABGESCHLOSSEN")
        print("="*70)
        print(f"  ✓ Erfolgreich:  {captured_count} Seiten")
        if skipped_count > 0:
            print(f"  ⏭️  Übersprungen:  {skipped_count} Seiten (bereits vorhanden)")
        if failed_pages:
            print(f"  ❌ Fehlgeschlagen: {len(failed_pages)} Seiten: {failed_pages}")
        
        total_saved = len(list(out_dir.glob("page_*.png")))
        print(f"\n  📁 Gesamt im Ordner: {total_saved} Dateien")
        
        if failed_pages:
            print(f"\n  💡 Tipp: Starte erneut mit --start-index {failed_pages[0]} um fehlende Seiten nachzuholen")
        
        print("="*70)
        
        context.close()


# ---------- Phase B: Build (PDF + OCR + metadata) ----------

def build_pdf_from_images(images: List[Path], out_pdf: Path, dpi: Optional[int]) -> None:
    layout = None
    if dpi:
        layout = (dpi, dpi)
    with open(out_pdf, "wb") as f:
        f.write(img2pdf.convert([str(p) for p in images], dpi=layout))


def run_ocr(input_pdf: Path, output_pdf: Path, lang: str, jobs: int, optimize: int, pdfa: bool, deskew: bool) -> None:
    import subprocess
    cmd = [
        "ocrmypdf",
        "--language", lang,
        "--jobs", str(jobs),
        f"--optimize={optimize}",
        "--skip-text",
    ]
    if deskew:
        cmd.append("--deskew")
    if pdfa:
        cmd += ["--output-type", "pdfa"]

    cmd += [str(input_pdf), str(output_pdf)]
    subprocess.run(cmd, check=True)


def set_metadata(pdf_path: Path, title: Optional[str], author: Optional[str],
                 subject: Optional[str], keywords: Optional[List[str]]) -> None:
    with pikepdf.open(pdf_path) as pdf:
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
    pdfa: bool,
    deskew: bool,
    dpi: Optional[int],
    jpeg_quality: int,
    crop: bool,
    crop_threshold: int,
    crop_margin: int,
    title: Optional[str],
    author: Optional[str],
    subject: Optional[str],
    keywords_csv: Optional[str],
) -> None:

    images = list_images(input_dir)
    if not images:
        print("\n" + "="*70)
        print("❌ FEHLER: Keine Bilder gefunden!")
        print("="*70)
        print(f"Verzeichnis: {input_dir}")
        print("\nMögliche Ursachen:")
        print("  • Capture wurde noch nicht ausgeführt")
        print("  • Falsches Verzeichnis angegeben")
        print("  • Keine .png/.jpg Dateien vorhanden")
        print("\nLösung:")
        print(f"  Führe zuerst aus: ./capture.sh")
        print("="*70)
        sys.exit(1)
    
    print(f"✓ {len(images)} Bilder gefunden")
    print(f"  Erstes Bild: {images[0].name}")
    print(f"  Letztes Bild: {images[-1].name}")

    keywords = [k.strip() for k in keywords_csv.split(",")] if keywords_csv else None
    ensure_dir(output_pdf.parent)

    # Preprocess: convert to JPEG for size/performance balance
    tmpdir = Path(tempfile.mkdtemp())
    processed_dir = tmpdir / "processed"
    ensure_dir(processed_dir)
    processed = []

    print("\n" + "="*70)
    print("🖼️  SCHRITT 1/4: Bilder vorverarbeiten")
    print("="*70)
    print(f"Eingabe: {len(images)} Bilder")
    print(f"Aktionen: {'Crop + ' if crop else ''}JPEG-Konvertierung (Qualität {jpeg_quality})")
    print("="*70)

    for img_path in tqdm(images, desc="Verarbeite", unit="Bild"):
        with Image.open(img_path) as im:
            if crop:
                im = auto_crop_image(im, threshold=crop_threshold, margin_px=crop_margin)
            if im.mode in ('RGBA', 'P'):
                im = im.convert('RGB')
            out_file = processed_dir / (img_path.stem + ".jpg")
            im.save(out_file, format="JPEG", quality=jpeg_quality, optimize=True)
            processed.append(out_file)

    raw_pdf = tmpdir / "raw.pdf"
    print("\n" + "="*70)
    print("📄 SCHRITT 2/4: Erstelle Roh-PDF aus Bildern")
    print("="*70)
    build_pdf_from_images(processed, raw_pdf, dpi=dpi)
    pdf_size_mb = raw_pdf.stat().st_size / (1024*1024)
    print(f"✓ Roh-PDF erstellt: {pdf_size_mb:.1f} MB")

    ocr_pdf = tmpdir / "ocr.pdf"
    print("\n" + "="*70)
    print("🔤 SCHRITT 3/4: OCR-Texterkennung läuft...")
    print("="*70)
    print(f"Sprache: Deutsch ({lang})")
    print(f"Parallel-Jobs: {jobs}")
    print(f"Optimierung: Level {optimize}")
    print(f"Geschätzte Dauer: ~{len(images)//6} Minuten")
    print("\n💡 Dies kann einige Minuten dauern. Bitte warten...")
    print("="*70)
    run_ocr(
        input_pdf=raw_pdf,
        output_pdf=ocr_pdf,
        lang=lang,
        jobs=jobs,
        optimize=optimize,
        pdfa=pdfa,
        deskew=deskew
    )

    # Move to final output and set metadata
    print("\n" + "="*70)
    print("💾 SCHRITT 4/4: Finalisiere PDF")
    print("="*70)
    ocr_pdf.replace(output_pdf)
    set_metadata(output_pdf, title, author, subject, keywords)
    
    final_size = output_pdf.stat().st_size / (1024*1024)
    print(f"✓ Metadaten gesetzt")
    print(f"✓ PDF gespeichert: {output_pdf.name}")
    
    print(f"\n{'='*70}")
    print("🎉 PDF ERFOLGREICH ERSTELLT!")
    print(f"{'='*70}")
    print(f"📄 Datei:     {output_pdf}")
    print(f"💾 Größe:     {final_size:.1f} MB")
    print(f"📊 Seiten:    {len(images)}")
    print(f"🔤 OCR:       Deutsch (durchsuchbar)")
    print(f"{'='*70}")


# ---------- CLI ----------

def main():
    parser = argparse.ArgumentParser(description="Capture Edubase pages and build an OCR searchable PDF.")
    sub = parser.add_subparsers(dest="cmd", required=True)

    # capture subcommand
    cap = sub.add_parser("capture", help="Capture page screenshots from the viewer")
    cap.add_argument("--book-url", required=True, help="Book viewer URL (after login)")
    cap.add_argument("--pages", type=int, required=True, help="Total number of pages (e.g., 396)")
    cap.add_argument("--out-dir", default="./input_pages", help="Output directory for PNG pages")
    cap.add_argument("--user-data-dir", default="~/.pw_edubase", help="Persistent browser profile dir")
    cap.add_argument("--start-index", type=int, default=1, help="Start page index (default 1)")
    cap.add_argument("--viewer-selector", default=None, help="CSS selector for page element (optional)")
    cap.add_argument("--click-next-selector", default=None, help="CSS selector for next-page control (optional)")
    cap.add_argument("--advance-with-keys", action="store_true", help="Use ArrowRight to advance pages")
    cap.add_argument("--delay-ms", type=int, default=1200, help="Delay between pages (ms)")
    cap.add_argument("--fullpage", action="store_true", help="Always use fullpage screenshots")
    cap.add_argument("--crop", action="store_true", help="Auto-crop white margins (on captured images)")
    cap.add_argument("--crop-threshold", type=int, default=248, help="Crop white threshold (200–254)")
    cap.add_argument("--crop-margin", type=int, default=10, help="Extra margin (px) around content")

    # build subcommand
    bld = sub.add_parser("build", help="Build OCR-PDF from images")
    bld.add_argument("--input", default="./input_pages", help="Input images directory")
    bld.add_argument("--output", default="./output/book_final.pdf", help="Output PDF")
    bld.add_argument("--lang", default="deu", help="OCR language")
    bld.add_argument("--jobs", type=int, default=6, help="Parallel OCR jobs")
    bld.add_argument("--optimize", type=int, default=2, help="OCR optimization level (0–3)")
    bld.add_argument("--pdfa", action="store_true", help="Output as PDF/A")
    bld.add_argument("--deskew", action="store_true", help="Deskew pages during OCR")
    bld.add_argument("--dpi", type=int, default=None, help="Logical DPI to embed into PDF (optional)")
    bld.add_argument("--jpeg-quality", type=int, default=92, help="JPEG quality for preprocess (80–95)")
    bld.add_argument("--crop", action="store_true", help="Auto-crop white margins before PDF build")
    bld.add_argument("--crop-threshold", type=int, default=248, help="Crop white threshold")
    bld.add_argument("--crop-margin", type=int, default=10, help="Margin (px)")
    bld.add_argument("--title", default=None, help="PDF title metadata")
    bld.add_argument("--author", default=None, help="PDF author metadata")
    bld.add_argument("--subject", default=None, help="PDF subject metadata")
    bld.add_argument("--keywords", default=None, help="Comma-separated keywords")

    args = parser.parse_args()

    if args.cmd == "capture":
        out_dir = Path(args.out_dir).expanduser().resolve()
        user_data_dir = Path(args.user_data_dir).expanduser().resolve()
        capture_pages(
            book_url=args.book_url,
            total_pages=args.pages,
            out_dir=out_dir,
            user_data_dir=user_data_dir,
            viewer_selector=args.viewer_selector,
            start_index=args.start_index,
            per_page_delay_ms=args.delay_ms,
            fullpage=args.fullpage,
            crop=args.crop,
            crop_threshold=args.crop_threshold,
            crop_margin=args.crop_margin,
            click_next_selector=args.click_next_selector,
            advance_with_keys=args.advance_with_keys,
        )

    elif args.cmd == "build":
        input_dir = Path(args.input).expanduser().resolve()
        output_pdf = Path(args.output).expanduser().resolve()
        build_pipeline(
            input_dir=input_dir,
            output_pdf=output_pdf,
            lang=args.lang,
            jobs=args.jobs,
            optimize=args.optimize,
            pdfa=args.pdfa,
            deskew=args.deskew,
            dpi=args.dpi,
            jpeg_quality=args.jpeg_quality,
            crop=args.crop,
            crop_threshold=args.crop_threshold,
            crop_margin=args.crop_margin,
            title=args.title,
            author=args.author,
            subject=args.subject,
            keywords_csv=args.keywords,
        )


if __name__ == "__main__":
    main()
