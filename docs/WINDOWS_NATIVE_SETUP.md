# 🪟 Windows Native Setup Guide

**Edubase to PDF läuft jetzt vollständig nativ auf Windows - keine WSL2 mehr nötig!**

Dieses Tool funktioniert jetzt **100% nativ auf Windows** mit OCR-Unterstützung. Du benötigst **kein WSL2** mehr.

---

## 🎯 Überblick

### Was funktioniert nativ auf Windows?

✅ **ALLES!**
- ✅ Screenshot-Capture mit Playwright
- ✅ PDF-Erstellung mit img2pdf
- ✅ **OCR-Texterkennung mit Tesseract (DEUTSCH!)**
- ✅ PDF-Optimierung mit Ghostscript
- ✅ Automatisches Cropping
- ✅ Alle CLI-Features

### Voraussetzungen

- **Windows 10 1809+** oder **Windows 11**
- **Administratorrechte** (nur für Installation)
- **~500 MB freier Speicherplatz**
- **Internetverbindung** (für Downloads)

---

## 🚀 Schnellinstallation (5 Minuten)

### Option A: Automatisches Setup (EMPFOHLEN)

```cmd
setup_windows.bat
```

Das war's! Das Script installiert automatisch:
1. Python 3.11+ (falls nicht vorhanden)
2. Tesseract OCR mit deutschem Sprachpaket
3. Ghostscript (für PDF-Optimierung)
4. Alle Python-Abhängigkeiten
5. Chromium Browser für Screenshots

**Nach dem Setup:**
```cmd
.\capture.bat    # Screenshots erstellen
.\build.bat      # PDF mit OCR erstellen
```

---

### Option B: Manuelle Installation

Wenn du die Kontrolle behalten willst oder `setup_windows.bat` nicht funktioniert:

#### 1️⃣ Python installieren

**Mit winget (empfohlen):**
```powershell
winget install -e --id Python.Python.3.11
```

**Oder von https://www.python.org/downloads/** - Wichtig: "Add Python to PATH" ankreuzen!

Prüfen:
```cmd
python --version
```

#### 2️⃣ Tesseract OCR installieren

**Mit winget (empfohlen):**
```powershell
winget install -e --id UB-Mannheim.TesseractOCR
```

**Oder manuell:**
1. Download: https://github.com/UB-Mannheim/tesseract/wiki
2. Installiere das 64-bit Package
3. **WICHTIG:** Wähle während Installation "Additional language data" → "German"

Prüfen:
```cmd
tesseract --version
```

#### 3️⃣ Ghostscript installieren (optional, aber empfohlen)

**Mit winget:**
```powershell
winget install -e --id AGPL.Ghostscript
```

**Oder manuell:**
1. Download: https://www.ghostscript.com/download/gsdnld.html
2. Installiere die 64-bit Version

#### 4️⃣ Python Virtual Environment & Pakete

```cmd
REM Virtual Environment erstellen
python -m venv .venv

REM Aktivieren
.venv\Scripts\activate.bat

REM Pakete installieren
python -m pip install --upgrade pip
pip install -r requirements.txt

REM Browser installieren
playwright install chromium
```

#### 5️⃣ Installation testen

```cmd
REM Test OCR
python edubase_cli.py --help

REM Test Tesseract
tesseract --version

REM Test Browser
python test_browser_config.py
```

---

## 🎓 Nutzung

### Screenshots erstellen

**Option 1: Batch-Script (einfach)**
```cmd
.\capture.bat
```

**Option 2: CLI (flexibel)**
```cmd
.venv\Scripts\activate.bat
python edubase_cli.py capture --book-url "https://app.edubase.ch/#doc/60505/1" --pages 396
```

### PDF mit OCR erstellen

**Option 1: Batch-Script (einfach)**
```cmd
.\build.bat
```

**Option 2: CLI (flexibel)**
```cmd
.venv\Scripts\activate.bat
python edubase_cli.py build --input ./input_pages --output ./output/book.pdf --lang deu
```

---

## ⚙️ Erweiterte Konfiguration

### Tesseract Sprachpakete

**Deutsche Sprache ist bereits enthalten**, aber du kannst weitere hinzufügen:

**Englisch + Deutsch:**
1. Download `eng.traineddata` von: https://github.com/tesseract-ocr/tessdata
2. Kopiere nach: `C:\Program Files\Tesseract-OCR\tessdata\`
3. Nutze: `--lang deu+eng`

**Andere Sprachen:**
- Französisch: `fra.traineddata`
- Italienisch: `ita.traineddata`
- Spanisch: `spa.traineddata`

Download: https://github.com/tesseract-ocr/tessdata

### OCR-Qualität verbessern

**Höhere Auflösung:**
```cmd
python edubase_cli.py build --dpi 300 --optimize 1
```

**Mehrsprachige OCR:**
```cmd
python edubase_cli.py build --lang deu+eng
```

**Mehr CPU-Kerne nutzen:**
```cmd
python edubase_cli.py build --jobs 8
```

### PDF-Größe reduzieren

**Niedrigere JPEG-Qualität:**
```cmd
python edubase_cli.py build --jpeg-quality 85 --optimize 3
```

---

## 🐛 Troubleshooting

### ❌ "Python wurde nicht gefunden"

**Problem:** Python ist nicht im PATH

**Lösung 1:** Python neu installieren und "Add Python to PATH" ankreuzen

**Lösung 2:** Manuell zum PATH hinzufügen:
1. Suche "Umgebungsvariablen" in Windows
2. Bearbeite "Path"
3. Füge hinzu: `C:\Users\DEIN_NAME\AppData\Local\Programs\Python\Python311`
4. Füge hinzu: `C:\Users\DEIN_NAME\AppData\Local\Programs\Python\Python311\Scripts`
5. Öffne neues Terminal

### ❌ "tesseract ist nicht als interner oder externer Befehl erkannt"

**Problem:** Tesseract ist nicht im PATH

**Lösung 1:** Tesseract neu installieren (winget macht das automatisch)

**Lösung 2:** Manuell zum PATH hinzufügen:
1. Finde Tesseract-Installation: `C:\Program Files\Tesseract-OCR`
2. Füge zum PATH hinzu (siehe oben)
3. Öffne neues Terminal

**Lösung 3:** Manuell in `edubase_cli.py` setzen:
```python
# Am Anfang von edubase_cli.py hinzufügen:
os.environ['PATH'] += r';C:\Program Files\Tesseract-OCR'
```

### ❌ OCR findet deutsche Sprache nicht

**Problem:** Deutsches Sprachpaket fehlt

**Lösung:**
1. Download `deu.traineddata`: https://github.com/tesseract-ocr/tessdata/raw/main/deu.traineddata
2. Kopiere nach: `C:\Program Files\Tesseract-OCR\tessdata\deu.traineddata`
3. Prüfen: `tesseract --list-langs` sollte `deu` zeigen

### ❌ "ghostscript nicht gefunden" Warnung

**Problem:** Ghostscript nicht installiert oder nicht im PATH

**Auswirkung:** PDF-Optimierung funktioniert eingeschränkt, aber OCR funktioniert trotzdem!

**Lösung:**
```powershell
winget install -e --id AGPL.Ghostscript
```

Danach neues Terminal öffnen.

### ❌ Browser startet nicht

**Problem:** Playwright Browser fehlt oder Systemabhängigkeiten fehlen

**Lösung:**
```cmd
.venv\Scripts\activate.bat
playwright install chromium
playwright install-deps chromium
```

Falls `install-deps` nicht auf Windows funktioniert, ist das OK - meist nicht nötig.

### ❌ "winget" ist nicht verfügbar

**Problem:** Windows App Installer fehlt

**Lösung:**
1. Microsoft Store öffnen
2. Suche "App Installer"
3. Installieren/Aktualisieren
4. Terminal neu öffnen

**Oder:** Manuelle Installation (siehe Option B oben)

### ❌ OCR dauert sehr lange

**Normal!** OCR ist CPU-intensiv.

**Beschleunigen:**
```cmd
REM Mehr CPU-Kerne nutzen (z.B. 8 statt 6)
python edubase_cli.py build --jobs 8

REM Oder niedrigere DPI
python edubase_cli.py build --dpi 200
```

### ❌ PDF ist zu groß

**Lösung:**
```cmd
REM JPEG-Qualität reduzieren + maximale Kompression
python edubase_cli.py build --jpeg-quality 80 --optimize 3
```

---

## 📊 Performance

**Getestet auf Windows 11:**
- CPU: AMD Ryzen 5 5600X
- RAM: 16 GB
- SSD: NVMe

**Zeiten für 396 Seiten:**
| Phase           | Dauer     | CPU-Last |
|-----------------|-----------|----------|
| Capture         | ~10 Min   | Niedrig  |
| Preprocessing   | ~2 Min    | Mittel   |
| OCR (6 Jobs)    | ~15 Min   | Hoch     |
| Optimierung     | ~1 Min    | Mittel   |
| **GESAMT**      | **~28 Min**| -       |

**OCR ist auf Windows tendenziell etwas langsamer als auf Linux**, aber funktioniert einwandfrei!

---

## 🎯 Best Practices für Windows

### 1. Antivirus ausschalten während Capture

Manche Antivirus-Programme können Browser-Automation stören.

**Temporär Windows Defender ausschalten:**
1. Windows Security öffnen
2. "Virus & Bedrohungsschutz"
3. "Einstellungen verwalten"
4. "Echtzeitschutz" temporär ausschalten

**Vergiss nicht, ihn danach wieder einzuschalten!**

### 2. Energiesparplan auf "Höchstleistung"

Für schnellere OCR-Verarbeitung:
1. Suche "Energieoptionen" in Windows
2. Wähle "Höchstleistung"

### 3. Genug Speicherplatz

- Screenshots: ~200-500 MB (je nach Buchgröße)
- Temporäre Dateien: ~500 MB
- Finales PDF: ~50-100 MB

**Empfohlen: 2 GB frei auf C:**

### 4. Kein Browser minimieren

Während `capture.bat` läuft:
- ❌ Browser **NICHT** minimieren
- ❌ **NICHT** in Browser klicken
- ✅ OK: Andere Programme nutzen

---

## 🔍 Qualitätskontrolle

### Test nach Installation

**1. Test CLI:**
```cmd
python edubase_cli.py --help
```
Sollte Hilfe anzeigen.

**2. Test Tesseract:**
```cmd
tesseract --version
tesseract --list-langs
```
Sollte `deu` (Deutsch) in der Liste zeigen.

**3. Test Browser:**
```cmd
python test_browser_config.py
```
Browser sollte sich öffnen und schließen.

**4. Test OCR (Mini-Test):**
```cmd
REM Erstelle ein Test-Bild mit Text
echo Test > test.txt
REM ... oder nutze ein Screenshot

REM Test OCR
tesseract test.png output -l deu
type output.txt
```

---

## 🆚 Windows Nativ vs. WSL2

### Windows Nativ (diese Anleitung)

✅ **Vorteile:**
- Einfacher zu installieren
- Keine Linux-Kenntnisse nötig
- Native Windows-Integration
- GUI funktioniert out-of-the-box

⚠️ **Nachteile:**
- OCR etwas langsamer (~15% mehr Zeit)
- Mehr Speicher-Overhead
- Pfad-Handling komplizierter

### WSL2 (frühere Empfehlung)

✅ **Vorteile:**
- Schnellere OCR-Verarbeitung
- Weniger RAM-Verbrauch
- Native Linux-Tools

⚠️ **Nachteile:**
- Komplexeres Setup
- WSL2 + WSLg Konfiguration nötig
- Linux-Kenntnisse hilfreich

**Empfehlung:** **Windows Nativ für die meisten Nutzer!** WSL2 nur wenn:
- Du bereits WSL2 nutzt
- Du maximale Performance brauchst
- Du Linux bevorzugst

---

## 💡 Tipps & Tricks

### Virtual Environment automatisch aktivieren

**Erstelle `activate.bat` im Projekt-Root:**
```cmd
@echo off
call .venv\Scripts\activate.bat
echo Virtual Environment aktiviert!
echo.
echo Verfügbare Befehle:
echo   python edubase_cli.py --help
echo   .\capture.bat
echo   .\build.bat
echo.
cmd /k
```

Dann einfach `activate.bat` doppelklicken!

### PowerShell statt CMD

Alle `.bat` Scripte funktionieren auch in PowerShell!

**Für PowerShell-User:** Die `.ps1` Scripte sind optimiert für PowerShell-Features.

### Execution Policy für PowerShell

Falls `.ps1` Scripte nicht laufen:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 🔗 Ressourcen

### Downloads
- **Python:** https://www.python.org/downloads/
- **Tesseract:** https://github.com/UB-Mannheim/tesseract/wiki
- **Ghostscript:** https://www.ghostscript.com/download/gsdnld.html
- **winget:** https://aka.ms/getwinget

### Dokumentation
- **OCRmyPDF:** https://ocrmypdf.readthedocs.io/
- **Tesseract:** https://tesseract-ocr.github.io/
- **Playwright:** https://playwright.dev/

### Support
- **GitHub Issues:** [edubase-exporter/issues](../../issues)
- **README.md:** Hauptdokumentation

---

## ✅ Checkliste

Nach erfolgreicher Installation sollten alle diese Befehle funktionieren:

```cmd
☐ python --version
☐ tesseract --version
☐ tesseract --list-langs   (sollte "deu" zeigen)
☐ gswin64c --version       (optional)
☐ python edubase_cli.py --help
☐ python test_browser_config.py
```

Wenn alle ☑️ sind: **Glückwunsch! Setup ist komplett! 🎉**

---

## 📞 Hilfe benötigt?

1. **Lies zuerst:** Diese Anleitung + Troubleshooting-Sektion
2. **Prüfe:** Ob alle Checklisten-Punkte funktionieren
3. **GitHub Issue:** Erstelle ein Issue mit:
   - Windows-Version
   - Python-Version (`python --version`)
   - Tesseract-Version (`tesseract --version`)
   - Fehlermeldung (vollständig)
   - Was du bereits versucht hast

---

**🎉 Viel Erfolg mit nativem OCR auf Windows!**

Du brauchst **kein WSL2** mehr - alles läuft nativ! 🚀
