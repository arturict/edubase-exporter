# Edubase Exporter - Windows Setup Script
# Run this in PowerShell: .\setup.ps1

$ErrorActionPreference = "Stop"

# Colors
function Write-ColorOutput($Message, $Color = "White") {
    Write-Host $Message -ForegroundColor $Color
}

Clear-Host
Write-ColorOutput "========================================================================" Cyan
Write-ColorOutput "  📦 Edubase Exporter - Windows Setup" Cyan
Write-ColorOutput "========================================================================" Cyan
Write-Host ""

# Detect environment
$IsWSL = $false
if (Test-Path "/proc/version") {
    $IsWSL = (Get-Content "/proc/version") -match "microsoft"
}

if ($IsWSL) {
    Write-ColorOutput "Detected: WSL2" Green
    Write-Host ""
    Write-ColorOutput "You're in WSL! Use the Linux setup script instead:" Yellow
    Write-Host "  ./setup.sh"
    Write-Host ""
    exit 0
}

Write-ColorOutput "Detected: Windows" Green
Write-Host ""

# Check Python
Write-ColorOutput "➜ Checking Python..." Cyan
try {
    $pythonVersion = python --version 2>&1
    Write-ColorOutput "  ✓ $pythonVersion found" Green
} catch {
    Write-ColorOutput "  ✗ Python not found!" Red
    Write-Host ""
    Write-ColorOutput "Please install Python 3.8 or higher:" Yellow
    Write-Host "  1. Download from: https://www.python.org/downloads/"
    Write-Host "  2. Run installer"
    Write-Host "  3. ✓ Check 'Add Python to PATH'"
    Write-Host "  4. Run this script again"
    Write-Host ""
    pause
    exit 1
}
Write-Host ""

# Check for OCR tools
Write-ColorOutput "➜ Checking OCR dependencies..." Cyan
$hasOCR = $false
try {
    ocrmypdf --version | Out-Null
    $hasOCR = $true
    Write-ColorOutput "  ✓ OCR tools found" Green
} catch {
    Write-ColorOutput "  ⚠ OCR tools not found (expected on Windows)" Yellow
    Write-Host ""
    Write-ColorOutput "Note: Screenshots work great on Windows!" Green
    Write-ColorOutput "For OCR (PDF creation with text recognition):" Yellow
    Write-Host ""
    Write-Host "  Option 1: Use WSL2 (Recommended)"
    Write-Host "    • Run in PowerShell as Admin: wsl --install"
    Write-Host "    • Restart computer"
    Write-Host "    • Follow setup in docs/WINDOWS_SETUP.md"
    Write-Host ""
    Write-Host "  Option 2: Use Docker"
    Write-Host "    • Install Docker Desktop"
    Write-Host "    • Use OCRmyPDF Docker image"
    Write-Host ""
    Write-Host "  Option 3: Manual installation (advanced)"
    Write-Host "    • Install Tesseract OCR"
    Write-Host "    • Install Ghostscript"
    Write-Host "    • pip install ocrmypdf"
    Write-Host ""
}
Write-Host ""

# Create virtual environment
Write-ColorOutput "➜ Setting up Python virtual environment..." Cyan
if (Test-Path ".venv") {
    Write-ColorOutput "  ⚠ Virtual environment already exists" Yellow
    $recreate = Read-Host "Recreate it? (y/n)"
    if ($recreate -eq "y" -or $recreate -eq "Y") {
        Remove-Item -Recurse -Force .venv
        python -m venv .venv
        Write-ColorOutput "  ✓ Virtual environment recreated" Green
    } else {
        Write-ColorOutput "  ℹ Using existing virtual environment" Blue
    }
} else {
    python -m venv .venv
    Write-ColorOutput "  ✓ Virtual environment created" Green
}
Write-Host ""

# Activate virtual environment
Write-ColorOutput "➜ Activating virtual environment..." Cyan
& .\.venv\Scripts\Activate.ps1
Write-ColorOutput "  ✓ Virtual environment activated" Green
Write-Host ""

# Install Python packages
Write-ColorOutput "➜ Installing Python packages..." Cyan
Write-Host "  (This may take a few minutes...)"
python -m pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet
Write-ColorOutput "  ✓ Python packages installed" Green
Write-Host ""

# Install Playwright browser
Write-ColorOutput "➜ Installing Chromium browser..." Cyan
playwright install chromium
Write-ColorOutput "  ✓ Browser installed" Green
Write-Host ""

# Create directories
Write-ColorOutput "➜ Creating directories..." Cyan
New-Item -ItemType Directory -Force -Path "input_pages" | Out-Null
New-Item -ItemType Directory -Force -Path "output" | Out-Null
Write-ColorOutput "  ✓ Directories created" Green
Write-Host ""

# Run system check
Write-ColorOutput "➜ Running system check..." Cyan
Write-Host ""
python edubase_cli.py check
Write-Host ""

# Success
Write-ColorOutput "========================================================================" Green
Write-ColorOutput "  ✓ Setup Complete!" Green
Write-ColorOutput "========================================================================" Green
Write-Host ""
Write-ColorOutput "Next Steps:" White
Write-Host ""
Write-ColorOutput "  1. Capture screenshots (works great on Windows!):" White
Write-ColorOutput "     .\capture.ps1" Yellow
Write-Host "     or:"
Write-ColorOutput "     python edubase_cli.py capture --help" Yellow
Write-Host ""

if (-not $hasOCR) {
    Write-ColorOutput "  2. Build PDF with OCR:" White
    Write-ColorOutput "     For OCR, use WSL2 (recommended):" Yellow
    Write-Host "       • wsl --install (if not installed)"
    Write-Host "       • wsl"
    Write-Host "       • cd /mnt/c/path/to/this/folder"
    Write-Host "       • ./setup.sh"
    Write-Host "       • ./build_pdf.sh"
    Write-Host ""
    Write-ColorOutput "     See docs/WINDOWS_SETUP.md for detailed guide" Cyan
} else {
    Write-ColorOutput "  2. Build PDF with OCR:" White
    Write-ColorOutput "     .\build.ps1" Yellow
    Write-Host "     or:"
    Write-ColorOutput "     python edubase_cli.py build --help" Yellow
}

Write-Host ""
Write-ColorOutput "────────────────────────────────────────────────────────────────────" Cyan
Write-Host ""
Write-ColorOutput "Tips:" White
Write-Host "  • Edit capture.ps1 and build.ps1 to set your book ID"
Write-Host "  • Use 'python edubase_cli.py --help' for all commands"
Write-Host "  • Check docs/WINDOWS_SETUP.md for Windows-specific help"
Write-Host ""
Write-ColorOutput "For best experience: Use Windows Terminal (from Microsoft Store)" Cyan
Write-Host ""

pause
