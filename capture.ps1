# Edubase to PDF - Screenshot Capture (PowerShell - Native Windows)
# Run this in PowerShell: .\capture.ps1

$ErrorActionPreference = "Stop"

# Configuration - EDIT THESE VALUES
$BOOK_ID = "60505"
$PAGES = 396
$BOOK_URL = "https://app.edubase.ch/#doc/$BOOK_ID/1"

# Colors
$Green = [System.ConsoleColor]::Green
$Yellow = [System.ConsoleColor]::Yellow
$Red = [System.ConsoleColor]::Red
$Cyan = [System.ConsoleColor]::Cyan

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "  📸 Edubase to PDF - Screenshot Capture" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Book:   " -NoNewline
Write-Host $BOOK_URL -ForegroundColor Yellow
Write-Host "Pages:  " -NoNewline
Write-Host $PAGES -ForegroundColor Green
Write-Host ""

# Check if virtual environment exists
if (-not (Test-Path ".venv\Scripts\Activate.ps1")) {
    Write-Host "[ERROR] Virtual environment not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run setup_windows.bat first." -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

Write-Host "Starting capture..." -ForegroundColor Cyan
Write-Host ""
Write-Host "WICHTIG während Capture:" -ForegroundColor Yellow
Write-Host "  - Browser-Fenster NICHT minimieren" -ForegroundColor Yellow
Write-Host "  - NICHT in den Browser klicken" -ForegroundColor Yellow
Write-Host "  - OK: Andere Programme nutzen" -ForegroundColor Green
Write-Host ""

# Activate virtual environment
& .\.venv\Scripts\Activate.ps1

# Run capture with new CLI
python edubase_cli.py capture `
    --book-url "$BOOK_URL" `
    --pages $PAGES `
    --out-dir "./input_pages" `
    --delay-ms 1500 `
    --crop

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Capture failed!" -ForegroundColor Red
    Write-Host ""
    pause
    exit 1
}

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Green
Write-Host "  ✓ Capture Complete!" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next step: " -NoNewline
Write-Host ".\build.ps1" -ForegroundColor Yellow
Write-Host ""
pause

