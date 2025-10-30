# WSL2 + Playwright Configuration Guide

## Overview

This document explains how Playwright/Chromium is configured to work optimally with WSL2 + WSLg (Windows Subsystem for Linux GUI apps).

## WSL2 Architecture

```
┌─────────────────────────────────────────┐
│         Windows 11 Host                 │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │     WSLg (Wayland Compositor)     │ │
│  │   - Display: :0                   │ │
│  │   - Wayland: wayland-0            │ │
│  └───────────────────────────────────┘ │
│               ↕                         │
│  ┌───────────────────────────────────┐ │
│  │         WSL2 Ubuntu                │ │
│  │                                   │ │
│  │  ┌─────────────────────────────┐ │ │
│  │  │  Playwright → Chromium      │ │ │
│  │  │  Browser Instance           │ │ │
│  │  └─────────────────────────────┘ │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Current Configuration

### Browser Arguments (`edubase_cli.py` & `edubase_to_pdf.py`)

```python
browser_args = [
    '--disable-blink-features=AutomationControlled',
    '--disable-dev-shm-usage',  # Avoid /dev/shm issues in containers/WSL
]

if sys_info['is_wsl']:
    browser_args.extend([
        '--no-sandbox',                    # Required for WSL2 environment
        '--disable-setuid-sandbox',        # Additional sandbox bypass for WSL
        '--disable-gpu',                   # Disable GPU acceleration (better compatibility with WSLg)
        '--disable-software-rasterizer',   # Use default rasterizer
    ])
```

### Why These Settings?

#### `--no-sandbox`
- **Required** in WSL2 because the Linux kernel doesn't support all sandbox features
- Chromium's sandbox relies on kernel features that may not be available in WSL2
- Safe for local development/automation use cases

#### `--disable-setuid-sandbox`
- Additional sandbox bypass specific to setuid-based sandboxing
- Complements `--no-sandbox` for full WSL2 compatibility

#### `--disable-gpu`
- GPU acceleration in WSL2 can be unstable with WSLg
- Software rendering is more reliable for screenshot automation
- Trade-off: Slightly slower rendering, but much more stable

#### `--disable-software-rasterizer`
- Uses Chromium's default (hardware-accelerated where available)
- Better rendering quality for screenshots
- Works well with WSLg's display server

#### `--disable-dev-shm-usage`
- `/dev/shm` (shared memory) can have size limitations in WSL2
- Chromium uses disk instead for shared memory
- Prevents out-of-memory errors during long captures

#### `ignore_default_args=['--enable-automation']`
- Hides "Chrome is being controlled by automated test software" banner
- Better for screenshots (no banner visible)

## Viewport & Display Configuration

```python
viewport_config = {'width': 1920, 'height': 1080}
device_scale_factor = 1.0
```

### Why 1920x1080 with scale 1.0?

- **Standard resolution**: Works reliably across all WSL2 setups
- **WSLg auto-scaling**: WSLg compositor handles HiDPI scaling natively
- **No distortion**: 1.0 scale factor prevents rendering artifacts
- **Predictable**: Same viewport size regardless of host Windows DPI

### High-DPI Considerations

If you have a 4K or high-DPI Windows display:
- WSLg automatically scales the window for Windows
- Inside WSL2, Chromium renders at 1920x1080
- Windows displays it scaled up (looks crisp)
- Screenshots are 1920x1080 (consistent quality)

## Display Server (WSLg)

WSL2 uses **WSLg** (WSL GUI support) which provides:

```bash
DISPLAY=:0                    # X11 fallback
WAYLAND_DISPLAY=wayland-0     # Native Wayland (preferred)
XDG_RUNTIME_DIR=/run/user/1000/
```

### Wayland vs X11

- **Wayland** (default): Modern, better performance
- **X11** (fallback): Supported via XWayland
- Chromium automatically chooses best protocol
- Both work transparently

## System Requirements

### Required Graphics Libraries

```bash
sudo apt install -y \
    libgbm1 \
    libdrm2 \
    mesa-vulkan-drivers \
    libgl1-mesa-dri
```

Check with:
```bash
./check_wsl_environment.sh
```

### Playwright Dependencies

```bash
source .venv/bin/activate
playwright install-deps chromium
```

This installs:
- `fonts-liberation` - Web fonts
- `libnss3` - Network Security Services
- `libxss1` - X11 Screen Saver extension
- `libatk-bridge2.0-0` - Accessibility toolkit
- And ~50 other libraries

## Troubleshooting

### Browser doesn't start

```bash
# Check display server
echo $DISPLAY
echo $WAYLAND_DISPLAY

# Should show:
# :0
# wayland-0
```

If empty, restart WSL:
```powershell
wsl --shutdown
wsl
```

### "No protocol specified" error

```bash
# WSLg not properly initialized
# Restart WSL or Windows
```

### Screenshots are blank/black

```bash
# Add delay before first screenshot
time.sleep(2)  # After page.goto()

# Or increase wait time
page.wait_for_load_state("networkidle", timeout=15000)
```

### Browser window too small

```python
# Window maximization via JavaScript
page.evaluate("""() => {
    window.moveTo(0, 0);
    window.resizeTo(screen.availWidth, screen.availHeight);
}""")
```

### Performance issues

```python
# Reduce parallel jobs for OCR
--jobs 4  # instead of 6

# Increase delay between screenshots
--delay-ms 2000  # instead of 1200
```

## Testing the Configuration

### 1. Quick Display Test

```bash
# Install test tools
sudo apt install x11-apps

# Open test window
xeyes
```

You should see a window with eyes following your cursor.

### 2. Test Chromium Launch

```bash
source .venv/bin/activate
python -c "
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    browser = p.chromium.launch(headless=False, args=['--no-sandbox'])
    page = browser.new_page()
    page.goto('https://example.com')
    input('Press Enter to close...')
    browser.close()
"
```

### 3. Full Capture Test

```bash
python edubase_cli.py capture \
    --book-url "https://app.edubase.ch/#doc/60505/1" \
    --pages 1
```

## Performance Characteristics

### Screenshot Timing (WSL2)
- Page load: ~1-2 seconds
- Screenshot capture: ~0.3 seconds
- Total per page: ~1.5 seconds

### Memory Usage
- Chromium: ~300-500 MB
- Playwright: ~100 MB
- Python process: ~50 MB
- **Total**: ~500-650 MB per browser instance

### CPU Usage
- Screenshot capture: Low (5-10%)
- Page rendering: Medium (20-30%)
- OCR processing: High (80-100% on all cores)

## Advanced Configuration

### Use GPU Acceleration (Experimental)

```python
# Remove --disable-gpu for testing
# May be faster but less stable
browser_args = [
    '--no-sandbox',
    # '--disable-gpu',  # Commented out
    '--enable-features=VaapiVideoDecoder',  # Hardware video decode
]
```

⚠️ **Warning**: GPU acceleration in WSL2 is experimental and may crash.

### Custom Device Scale Factor

```python
# For high-quality screenshots
viewport_config = {'width': 2560, 'height': 1440}
device_scale_factor = 2.0

# Results in 5120x2880 screenshots (large files!)
```

### Headless Mode (No Window)

```python
# Faster, but can't monitor progress
context = p.chromium.launch_persistent_context(
    user_data_dir=str(user_data_dir),
    headless=True,  # No window
    # ...
)
```

⚠️ **Note**: Some websites detect headless mode and may block access.

## Environment Check Script

Run the diagnostic script:

```bash
./check_wsl_environment.sh
```

Output shows:
- ✓ WSL2 version
- ✓ Display configuration
- ✓ Graphics libraries
- ✓ Playwright dependencies
- ⚠ Warnings/missing packages

## References

- [WSL GUI Apps Documentation](https://learn.microsoft.com/windows/wsl/tutorials/gui-apps)
- [Playwright Python API](https://playwright.dev/python/docs/intro)
- [Chromium Command Line Switches](https://peter.sh/experiments/chromium-command-line-switches/)
- [WSLg Architecture](https://github.com/microsoft/wslg)

## Summary

The current configuration is **optimized for reliability over performance**:

✅ Stable screenshot capture  
✅ Consistent rendering across displays  
✅ No GPU-related crashes  
✅ Works on all WSL2 setups  
❌ Slightly slower than native Windows  
❌ No hardware acceleration  

For production use (automated book exports), this is the **recommended configuration**.
