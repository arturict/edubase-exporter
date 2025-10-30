# Edubase to PDF - PDF Builder (PowerShell - Native Windows mit OCR!)
# Run this in PowerShell: .\build.ps1

$ErrorActionPreference = "Stop"

# Configuration - EDIT THESE VALUES
$BOOK_ID = "60505"
$OUTPUT_FILE = ".\output\edubase_$BOOK_ID.pdf"
$BOOK_TITLE = "Edubase Book $BOOK_ID"
$BOOK_AUTHOR = "Edubase"

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "  📚 Edubase to PDF - PDF Builder with OCR (Native Windows)" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Input:  .\input_pages\" -ForegroundColor Yellow
Write-Host "Output: $OUTPUT_FILE" -ForegroundColor Green
Write-Host ""

# Check if virtual environment exists
if (-not (Test-Path ".venv\Scripts\Activate.ps1")) {
    Write-Host "[ERROR] Virtual environment not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run setup_windows.bat first." -ForegroundColor Yellow
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

# Check for Tesseract
$tesseractExists = Get-Command tesseract -ErrorAction SilentlyContinue
if (-not $tesseractExists) {
    Write-Host "[WARNING] Tesseract OCR not found in PATH!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "OCR wird nicht funktionieren ohne Tesseract." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Install mit:  " -NoNewline
    Write-Host "winget install -e --id UB-Mannheim.TesseractOCR" -ForegroundColor Cyan
    Write-Host "Oder folge:   docs\WINDOWS_NATIVE_SETUP.md" -ForegroundColor Cyan
    Write-Host ""
    pause
}

Write-Host "Starting PDF build with OCR..." -ForegroundColor Cyan
Write-Host ""

# Activate virtual environment
& .\.venv\Scripts\Activate.ps1

# Run build with new CLI
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
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Stelle sicher dass Tesseract installiert ist:" -ForegroundColor Yellow
    Write-Host "     winget install -e --id UB-Mannheim.TesseractOCR" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  2. Prüfe ob deutsche Sprache verfügbar ist:" -ForegroundColor Yellow
    Write-Host "     tesseract --list-langs" -ForegroundColor Cyan
    Write-Host "     (sollte 'deu' zeigen)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  3. Siehe vollständige Anleitung:" -ForegroundColor Yellow
    Write-Host "     docs\WINDOWS_NATIVE_SETUP.md" -ForegroundColor Cyan
    Write-Host ""
    pause
    exit 1
}

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Green
Write-Host "  ✓ SUCCESS! PDF created!" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "PDF Location: " -NoNewline
Write-Host "$OUTPUT_FILE" -ForegroundColor Yellow
Write-Host ""
Write-Host "To open the PDF:" -ForegroundColor Cyan
Write-Host "  start $OUTPUT_FILE" -ForegroundColor Yellow
Write-Host ""
Write-Host "To test OCR (text should be searchable):" -ForegroundColor Cyan
Write-Host "  Open PDF and press Ctrl+F" -ForegroundColor Yellow
Write-Host ""
pause

