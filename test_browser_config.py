#!/usr/bin/env python3
"""
Quick Browser Test for WSL2 Configuration
Tests that Chromium launches correctly with optimized settings
"""
import sys
import time
from pathlib import Path

try:
    from playwright.sync_api import sync_playwright
    from rich.console import Console
    from rich.panel import Panel
except ImportError:
    print("❌ Dependencies not installed!")
    print("Run: source .venv/bin/activate && pip install -r requirements.txt")
    sys.exit(1)

console = Console()


def get_system_info():
    """Get system information"""
    import platform
    return {
        'os': platform.system(),
        'is_wsl': 'microsoft' in platform.uname().release.lower(),
        'python_version': platform.python_version(),
    }


def test_browser_launch():
    """Test browser launch with WSL2-optimized settings"""
    
    sys_info = get_system_info()
    
    console.print()
    console.print(Panel.fit(
        f"[bold cyan]Browser Configuration Test[/bold cyan]\n\n"
        f"Platform: [yellow]{sys_info['os']}[/yellow]\n"
        f"WSL2: [{'green' if sys_info['is_wsl'] else 'red'}]{sys_info['is_wsl']}[/]\n"
        f"Python: [blue]{sys_info['python_version']}[/blue]",
        title="[bold]Environment[/bold]",
        border_style="cyan"
    ))
    console.print()
    
    # Browser configuration
    browser_args = [
        '--disable-blink-features=AutomationControlled',
        '--disable-dev-shm-usage',
    ]
    
    if sys_info['is_wsl']:
        browser_args.extend([
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-gpu',
            '--disable-software-rasterizer',
        ])
        console.print("[yellow]⚙ WSL2-specific arguments enabled[/yellow]")
    else:
        console.print("[blue]ℹ Running on native Linux/macOS[/blue]")
    
    console.print()
    
    # Test browser launch
    console.print("[bold]Testing Browser Launch...[/bold]")
    console.print()
    
    try:
        with console.status("[bold green]Starting Chromium..."):
            with sync_playwright() as p:
                browser = p.chromium.launch(
                    headless=False,
                    args=browser_args,
                )
                
                console.print("[green]✓[/green] Browser launched successfully")
                
                # Create page
                page = browser.new_page(
                    viewport={'width': 1920, 'height': 1080},
                    device_scale_factor=1.0,
                )
                console.print("[green]✓[/green] Page created (1920x1080, scale 1.0)")
                
                # Navigate to test page
                console.print("[blue]→[/blue] Loading test page...")
                page.goto('https://example.com', wait_until='domcontentloaded')
                console.print("[green]✓[/green] Page loaded")
                
                # Test window maximization
                try:
                    page.evaluate("""() => {
                        window.moveTo(0, 0);
                        window.resizeTo(screen.availWidth, screen.availHeight);
                    }""")
                    console.print("[green]✓[/green] Window maximized")
                except Exception as e:
                    console.print(f"[yellow]⚠[/yellow] Window maximization failed: {e}")
                
                # Take screenshot
                console.print("[blue]→[/blue] Taking test screenshot...")
                screenshot_path = Path('test_screenshot.png')
                page.screenshot(path=str(screenshot_path))
                size_kb = screenshot_path.stat().st_size / 1024
                console.print(f"[green]✓[/green] Screenshot saved: {screenshot_path} ({size_kb:.0f} KB)")
                
                # Wait for user
                console.print()
                console.print(Panel(
                    "[yellow]Browser window is open![/yellow]\n\n"
                    "You should see:\n"
                    "• Chromium window with example.com\n"
                    "• No 'automation' banner\n"
                    "• Clear, readable text\n\n"
                    "Press [bold]Enter[/bold] to close and continue...",
                    border_style="yellow"
                ))
                input()
                
                browser.close()
                console.print("[green]✓[/green] Browser closed")
        
        # Success summary
        console.print()
        console.print(Panel.fit(
            "[bold green]✓ All Tests Passed![/bold green]\n\n"
            "Configuration is working correctly.\n"
            "Ready for production use!",
            title="[bold]Success[/bold]",
            border_style="green"
        ))
        console.print()
        
        # Cleanup
        if screenshot_path.exists():
            screenshot_path.unlink()
            console.print("[dim]Test screenshot cleaned up[/dim]")
        
        return True
        
    except Exception as e:
        console.print()
        console.print(Panel.fit(
            f"[bold red]✗ Test Failed[/bold red]\n\n"
            f"Error: {str(e)}\n\n"
            f"Check:\n"
            f"1. Playwright is installed: playwright install chromium\n"
            f"2. System dependencies: ./check_wsl_environment.sh\n"
            f"3. Display is configured: echo $DISPLAY",
            title="[bold]Error[/bold]",
            border_style="red"
        ))
        console.print()
        return False


def main():
    """Main entry point"""
    try:
        success = test_browser_launch()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        console.print("\n[yellow]Test interrupted by user[/yellow]")
        sys.exit(1)


if __name__ == "__main__":
    main()
