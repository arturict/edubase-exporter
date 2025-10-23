# Edubase to PDF - PDF Builder (PowerShell)
# Run this in PowerShell: .\build.ps1

$ErrorActionPreference = "Stop"

# Configuration - EDIT THESE VALUES
$BOOK_ID = "60505"
$OUTPUT_FILE = ".\output\edubase_$BOOK_ID.pdf"
$BOOK_TITLE = "Edubase Book $BOOK_ID"
$BOOK_AUTHOR = "Edubase"

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "  📚 Edubase to PDF - PDF Builder with OCR" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Input:  .\input_pages\" -ForegroundColor Yellow
Write-Host "Output: $OUTPUT_FILE" -ForegroundColor Green
Write-Host ""

# Check if virtual environment exists
if (-not (Test-Path ".venv\Scripts\Activate.ps1")) {
    Write-Host "[ERROR] Virtual environment not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run setup first." -ForegroundColor Yellow
    pause
    exit 1
}

# Check if screenshots exist
$screenshotCount = (Get-ChildItem -Path "input_pages\page_*.png" -ErrorAction SilentlyContinue).Count
if ($screenshotCount -eq 0) {
    Write-Host "[ERROR] No screenshots found in input_pages\" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run " -NoNewline
    Write-Host ".\capture.ps1" -ForegroundColor Yellow -NoNewline
    Write-Host " first!"
    Write-Host ""
    pause
    exit 1
}

Write-Host "Found $screenshotCount screenshots" -ForegroundColor Green
Write-Host ""

# Activate virtual environment
& .\.venv\Scripts\Activate.ps1

# Run build with new CLI
Write-Host "Building PDF with OCR..." -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTE: This requires ocrmypdf and tesseract." -ForegroundColor Yellow
Write-Host "      On Windows, use WSL for best compatibility." -ForegroundColor Yellow
Write-Host ""

python edubase_cli.py build `
    --input "./input_pages" `
    --output "$OUTPUT_FILE" `
    --lang deu `
    --jobs 6 `
    --optimize 2 `
    --dpi 300 `
    --title "$BOOK_TITLE" `
    --author "$BOOK_AUTHOR" `
    --subject "Personal study copy (OCR)" `
    --crop

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] PDF creation failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "NOTE: OCR requires ocrmypdf which may not work natively on Windows." -ForegroundColor Yellow
    Write-Host "      Please use WSL (Windows Subsystem for Linux) instead:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "      1. Install WSL: wsl --install" -ForegroundColor Cyan
    Write-Host "      2. Open WSL terminal" -ForegroundColor Cyan
    Write-Host "      3. Navigate to this folder" -ForegroundColor Cyan
    Write-Host "      4. Run: ./capture.sh and ./build.sh" -ForegroundColor Cyan
    Write-Host ""
    pause
    exit 1
}

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Green
Write-Host "  🎉 Success! PDF created!" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "To open the PDF:" -ForegroundColor Cyan
Write-Host "  start $OUTPUT_FILE" -ForegroundColor Yellow
Write-Host ""
pause
