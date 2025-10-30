# 🚀 Edubase to PDF - Windows Quickstart

**Komplette Anleitung in 3 Schritten - läuft 100% nativ auf Windows!**

---

## ✨ Warum Windows Nativ?

- ✅ **Keine WSL2** Installation nötig
- ✅ **Vollständige OCR-Unterstützung** (Deutsch!)
- ✅ **Einfaches Setup** - nur 5 Minuten
- ✅ **Native Performance** - keine Virtualisierung

---

## 📦 Schritt 1: Automatisches Setup (2 Minuten)

**Öffne Command Prompt oder PowerShell im Projekt-Ordner:**

```cmd
setup_windows.bat
```

**Das war's!** Das Script installiert automatisch:
- Python 3.11+
- Tesseract OCR (Deutsch)
- Ghostscript
- Alle Python-Pakete
- Chromium Browser

**⚠️ Wichtig:** Nach der Installation öffne ein **NEUES** Terminal!

---

## 📸 Schritt 2: Screenshots erstellen (10-15 Minuten)

```cmd
.\capture.bat
```

**Was passiert:**
1. Browser öffnet sich mit Edubase
2. Du loggst dich ein (nur beim ersten Mal)
3. Du stellst den Viewer ein (Zoom, Fit to page)
4. Du drückst Enter → Screenshots werden automatisch erstellt

**Während Capture läuft:**
- ❌ Browser **NICHT** minimieren
- ❌ **NICHT** in Browser klicken
- ✅ Andere Programme nutzen ist OK ☕

---

## 📚 Schritt 3: PDF mit OCR erstellen (15-20 Minuten)

```cmd
.\build.bat
```

**Was passiert:**
1. Bilder werden vorverarbeitet & optimiert
2. PDF wird erstellt
3. Deutsche OCR-Texterkennung läuft
4. PDF wird optimiert

**Ergebnis:** `output\edubase_60505.pdf` - Vollständig durchsuchbar! 🎉

---

## 🎯 Anderes Buch exportieren?

**1. Bearbeite `capture.bat`:**
```bat
set BOOK_ID=DEINE_BUCH_ID
set PAGES=ANZAHL_SEITEN
```

**2. Bearbeite `build.bat`:**
```bat
set BOOK_ID=DEINE_BUCH_ID
set BOOK_TITLE=Dein Buchtitel
```

**3. Führe aus:**
```cmd
.\capture.bat
.\build.bat
```

---

## 🔧 Oder nutze den CLI direkt (Flexibler)

**Aktiviere Virtual Environment:**
```cmd
.venv\Scripts\activate.bat
```

**Screenshots:**
```cmd
python edubase_cli.py capture ^
    --book-url "https://app.edubase.ch/#doc/12345/1" ^
    --pages 250 ^
    --delay-ms 2000
```

**PDF mit OCR:**
```cmd
python edubase_cli.py build ^
    --input ./input_pages ^
    --output ./output/mein_buch.pdf ^
    --lang deu ^
    --jobs 8 ^
    --dpi 300
```

**Alle Optionen anzeigen:**
```cmd
python edubase_cli.py --help
python edubase_cli.py capture --help
python edubase_cli.py build --help
```

---

## 🐛 Troubleshooting

### ❌ "Python wurde nicht gefunden"

**Lösung:** Terminal neu öffnen nach Python-Installation

### ❌ "tesseract is not recognized"

**Lösung:**
```powershell
winget install -e --id UB-Mannheim.TesseractOCR
```
Dann Terminal neu öffnen.

### ❌ OCR findet deutsche Sprache nicht

**Prüfen:**
```cmd
tesseract --list-langs
```

Sollte `deu` zeigen. Falls nicht:
1. Download: https://github.com/tesseract-ocr/tessdata/raw/main/deu.traineddata
2. Kopiere nach: `C:\Program Files\Tesseract-OCR\tessdata\`

### ❌ Browser startet nicht

**Lösung:**
```cmd
.venv\Scripts\activate.bat
playwright install chromium
```

---

## 📖 Mehr Details?

- **Vollständige Windows-Anleitung:** [docs/WINDOWS_NATIVE_SETUP.md](docs/WINDOWS_NATIVE_SETUP.md)
- **Hauptdokumentation:** [README.md](../README.md)
- **CLI-Referenz:** `python edubase_cli.py --help`

---

## ✅ Checkliste

Nach Setup sollten diese Befehle funktionieren:

```cmd
python --version              ← Sollte Python 3.11+ zeigen
tesseract --version           ← Sollte Tesseract zeigen
tesseract --list-langs        ← Sollte "deu" enthalten
python edubase_cli.py --help  ← Sollte Hilfe zeigen
```

Wenn alle ✅ sind: **Setup erfolgreich!** 🎉

---

**🎓 Viel Erfolg mit deinem durchsuchbaren PDF!**

Alles läuft nativ auf Windows - kein WSL2, keine Docker, keine Kompromisse! 🚀
