@echo off
REM Edubase to PDF - Automatisches Windows Setup
REM Dieses Script installiert alle Abhängigkeiten für Windows (nativ)

echo.
echo ========================================================================
echo   📦 Edubase to PDF - Windows Setup
echo ========================================================================
echo.
echo Dieses Script installiert automatisch:
echo   - Python 3.11+ (falls nicht installiert)
echo   - Tesseract OCR mit deutschem Sprachpaket
echo   - Ghostscript (für PDF-Optimierung)
echo   - Python-Abhängigkeiten
echo   - Playwright Browser
echo.
echo ⚠️  HINWEIS: Administratorrechte erforderlich!
echo.
pause

REM Check if winget is available
where winget >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] winget ist nicht verfügbar!
    echo.
    echo winget ist ab Windows 10 1809+ oder Windows 11 verfügbar.
    echo Bitte installiere Windows App Installer aus dem Microsoft Store.
    echo.
    pause
    exit /b 1
)

echo ========================================================================
echo Schritt 1: Python installieren
echo ========================================================================
echo.

REM Check if Python is already installed
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Python ist bereits installiert:
    python --version
    echo.
) else (
    echo Python wird installiert...
    winget install -e --id Python.Python.3.11
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Python-Installation fehlgeschlagen!
        pause
        exit /b 1
    )
    echo ✓ Python erfolgreich installiert
    echo.
    echo WICHTIG: Bitte schließe dieses Fenster und öffne ein NEUES Terminal!
    echo.
    pause
    exit /b 0
)

echo ========================================================================
echo Schritt 2: Tesseract OCR installieren
echo ========================================================================
echo.

REM Check if Tesseract is already installed
where tesseract >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Tesseract ist bereits installiert:
    tesseract --version 2>&1 | findstr /C:"tesseract"
    echo.
) else (
    echo Tesseract OCR wird installiert (inkl. deutsche Sprache)...
    winget install -e --id UB-Mannheim.TesseractOCR
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Tesseract-Installation fehlgeschlagen!
        pause
        exit /b 1
    )
    echo ✓ Tesseract erfolgreich installiert
    echo.
)

echo ========================================================================
echo Schritt 3: Ghostscript installieren (optional)
echo ========================================================================
echo.

REM Check if Ghostscript is already installed
where gswin64c >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Ghostscript ist bereits installiert
    echo.
) else (
    echo Ghostscript wird installiert (für PDF-Optimierung)...
    winget install -e --id AGPL.Ghostscript
    if %ERRORLEVEL% NEQ 0 (
        echo [WARNUNG] Ghostscript-Installation fehlgeschlagen (optional)
        echo PDF-Optimierung wird möglicherweise eingeschränkt sein.
        echo.
    ) else (
        echo ✓ Ghostscript erfolgreich installiert
        echo.
    )
)

echo ========================================================================
echo Schritt 4: Python Virtual Environment erstellen
echo ========================================================================
echo.

if exist ".venv\" (
    echo Virtual Environment existiert bereits
    echo.
) else (
    echo Virtual Environment wird erstellt...
    python -m venv .venv
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Virtual Environment konnte nicht erstellt werden!
        pause
        exit /b 1
    )
    echo ✓ Virtual Environment erstellt
    echo.
)

echo ========================================================================
echo Schritt 5: Python-Pakete installieren
echo ========================================================================
echo.

call .venv\Scripts\activate.bat
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Virtual Environment konnte nicht aktiviert werden!
    pause
    exit /b 1
)

echo Python-Pakete werden installiert...
python -m pip install --upgrade pip
pip install -r requirements.txt
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Installation der Python-Pakete fehlgeschlagen!
    pause
    exit /b 1
)

echo ✓ Python-Pakete installiert
echo.

echo ========================================================================
echo Schritt 6: Playwright Browser installieren
echo ========================================================================
echo.

echo Chromium Browser wird heruntergeladen...
playwright install chromium
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Browser-Installation fehlgeschlagen!
    pause
    exit /b 1
)

echo ✓ Browser installiert
echo.

echo ========================================================================
echo   ✓ SETUP ERFOLGREICH ABGESCHLOSSEN!
echo ========================================================================
echo.
echo Alle Komponenten wurden erfolgreich installiert:
echo   ✓ Python
echo   ✓ Tesseract OCR (Deutsch)
echo   ✓ Ghostscript
echo   ✓ Python-Pakete
echo   ✓ Chromium Browser
echo.
echo ========================================================================
echo   📖 NÄCHSTE SCHRITTE
echo ========================================================================
echo.
echo 1. Schließe dieses Fenster
echo 2. Öffne ein NEUES PowerShell-Fenster
echo 3. Führe aus: .\capture.bat
echo.
echo Oder nutze den CLI direkt:
echo   .venv\Scripts\python.exe edubase_cli.py --help
echo.
pause
