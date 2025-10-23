@echo off
REM Edubase to PDF - PDF Builder (Windows)
REM Run this in Command Prompt or PowerShell

setlocal enabledelayedexpansion

REM Configuration - EDIT THESE VALUES
set BOOK_ID=60505
set OUTPUT_FILE=.\output\edubase_%BOOK_ID%.pdf
set BOOK_TITLE=Edubase Book %BOOK_ID%
set BOOK_AUTHOR=Edubase

echo.
echo ========================================================================
echo   Edubase to PDF - PDF Builder with OCR
echo ========================================================================
echo.
echo Input:  .\input_pages\
echo Output: %OUTPUT_FILE%
echo.

REM Check if virtual environment exists
if not exist ".venv\Scripts\activate.bat" (
    echo [ERROR] Virtual environment not found!
    echo.
    echo Please run setup first.
    echo.
    pause
    exit /b 1
)

REM Check if screenshots exist
if not exist "input_pages\page_*.png" (
    echo [ERROR] No screenshots found in input_pages\
    echo.
    echo Please run capture.bat first!
    echo.
    pause
    exit /b 1
)

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
    echo NOTE: OCR requires ocrmypdf which may not work natively on Windows.
    echo       Consider using WSL (Windows Subsystem for Linux) instead.
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================================================
echo   Success! PDF created: %OUTPUT_FILE%
echo ========================================================================
echo.
echo To open the PDF, run:
echo   start %OUTPUT_FILE%
echo.
pause
