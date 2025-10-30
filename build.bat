@echo off
REM Edubase to PDF - PDF Builder (Windows Nativ mit OCR!)
REM Run this in Command Prompt or PowerShell

setlocal enabledelayedexpansion

REM Configuration - EDIT THESE VALUES
set BOOK_ID=60505
set OUTPUT_FILE=.\output\edubase_%BOOK_ID%.pdf
set BOOK_TITLE=Edubase Book %BOOK_ID%
set BOOK_AUTHOR=Edubase

echo.
echo ========================================================================
echo   📚 Edubase to PDF - PDF Builder with OCR (Native Windows)
echo ========================================================================
echo.
echo Input:  .\input_pages\
echo Output: %OUTPUT_FILE%
echo.

REM Check if virtual environment exists
if not exist ".venv\Scripts\activate.bat" (
    echo [ERROR] Virtual environment not found!
    echo.
    echo Please run setup_windows.bat first.
    echo.
    pause
    exit /b 1
)

REM Check if screenshots exist
dir input_pages\page_*.png >nul 2>nul
if errorlevel 1 (
    echo [ERROR] No screenshots found in input_pages\
    echo.
    echo Please run capture.bat first!
    echo.
    pause
    exit /b 1
)

REM Count screenshots
for /f %%A in ('dir /b input_pages\page_*.png 2^>nul ^| find /c /v ""') do set COUNT=%%A
echo Found %COUNT% screenshots
echo.

REM Check for Tesseract
where tesseract >nul 2>nul
if errorlevel 1 (
    echo [WARNING] Tesseract OCR not found in PATH!
    echo.
    echo OCR wird nicht funktionieren ohne Tesseract.
    echo.
    echo Install mit:  winget install -e --id UB-Mannheim.TesseractOCR
    echo Oder folge:   docs\WINDOWS_NATIVE_SETUP.md
    echo.
    pause
)

echo Starting PDF build with OCR...
echo.

REM Activate virtual environment
call .venv\Scripts\activate.bat

REM Run build with new CLI
python edubase_cli.py build ^
    --input "./input_pages" ^
    --output "%OUTPUT_FILE%" ^
    --lang deu ^
    --jobs 6 ^
    --optimize 2 ^
    --dpi 300 ^
    --title "%BOOK_TITLE%" ^
    --author "%BOOK_AUTHOR%" ^
    --subject "Personal study copy (OCR)" ^
    --crop

if errorlevel 1 (
    echo.
    echo [ERROR] PDF creation failed!
    echo.
    echo Troubleshooting:
    echo   1. Stelle sicher dass Tesseract installiert ist:
    echo      winget install -e --id UB-Mannheim.TesseractOCR
    echo.
    echo   2. Prüfe ob deutsche Sprache verfügbar ist:
    echo      tesseract --list-langs
    echo      (sollte 'deu' zeigen)
    echo.
    echo   3. Siehe vollständige Anleitung:
    echo      docs\WINDOWS_NATIVE_SETUP.md
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================================================
echo   ✓ SUCCESS! PDF created!
echo ========================================================================
echo.
echo PDF Location: %OUTPUT_FILE%
echo.
echo To open the PDF:
echo   start %OUTPUT_FILE%
echo.
echo To test OCR (text should be searchable):
echo   Open PDF and press Ctrl+F
echo.
pause

