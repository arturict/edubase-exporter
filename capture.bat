@echo off
REM Edubase to PDF - Screenshot Capture (Windows)
REM Run this in Command Prompt or PowerShell

setlocal enabledelayedexpansion

REM Configuration - EDIT THESE VALUES
set BOOK_ID=60505
set PAGES=396
set BOOK_URL=https://app.edubase.ch/#doc/%BOOK_ID%/1

REM Colors not available in basic cmd, but script works fine
echo.
echo ========================================================================
echo   Edubase to PDF - Screenshot Capture
echo ========================================================================
echo.
echo Book:   %BOOK_URL%
echo Pages:  %PAGES%
echo.

REM Check if virtual environment exists
if not exist ".venv\Scripts\activate.bat" (
    echo [ERROR] Virtual environment not found!
    echo.
    echo Please run setup first:
    echo   python -m venv .venv
    echo   .venv\Scripts\activate.bat
    echo   pip install -r requirements.txt
    echo   playwright install chromium
    echo.
    pause
    exit /b 1
)

REM Activate virtual environment
call .venv\Scripts\activate.bat

REM Run capture with new CLI
python edubase_cli.py capture ^
    --book-url "%BOOK_URL%" ^
    --pages %PAGES% ^
    --out-dir "./input_pages" ^
    --delay-ms 1500 ^
    --crop

if errorlevel 1 (
    echo.
    echo [ERROR] Capture failed!
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================================================
echo   Next step: Run build.bat to create PDF
echo ========================================================================
echo.
pause
