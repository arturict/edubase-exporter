# 📚 Edubase to PDF Exporter

**Erstelle durchsuchbare PDFs aus Edubase-Büchern mit nur 2 einfachen Befehlen.**

Dieses Tool macht Screenshots von deinem Edubase-Buch und wandelt sie in ein durchsuchbares PDF mit deutscher OCR-Texterkennung um.

## 🪟 **NEU: 100% Native Windows-Unterstützung!**

**ALLES funktioniert jetzt nativ auf Windows - inklusive OCR mit deutschem Tesseract!**

```cmd
# Automatisches Setup (5 Minuten):
setup_windows.bat

# Screenshots erstellen:
.\capture.bat

# PDF mit OCR erstellen:
.\build.bat

# Fertig! 🎉
```

**Kein WSL2, keine Docker, keine Kompromisse - alles läuft nativ!** 🚀

📖 **Guides:**
- [Windows Quickstart](docs/WINDOWS_QUICKSTART.md) - 3 Schritte zum fertigen PDF
- [Windows Native Setup](docs/WINDOWS_NATIVE_SETUP.md) - Vollständige Anleitung
- [Implementation Details](WINDOWS_NATIVE_IMPLEMENTATION.md) - Technische Details

---

**⚠️ WICHTIGER HINWEIS:** Du bist selbst verantwortlich für die rechtmäßige Nutzung dieses Tools. Siehe [LICENSE](LICENSE) für Details.

---

## 🎯 Features

✨ **Super einfach** - Nur 2 Befehle: `./capture.sh` → `./build_pdf.sh` (oder `.bat` auf Windows)  
🪟 **Windows Nativ** - Automatisches Setup mit `setup_windows.bat` - KEIN WSL2 nötig!  
🔐 **Sicherer Login** - Einmalig einloggen, danach automatisch wiederverwendet  
🔍 **Durchsuchbar** - Vollständige OCR-Texterkennung auf Deutsch (auch auf Windows!)  
✂️ **Auto-Crop** - Entfernt automatisch weiße Ränder  
📊 **Fortschritt** - Zeigt genau, was gerade passiert  
⚡ **Schnell** - 396 Seiten in ~10-12 Minuten Screenshots, ~15-20 Min OCR  
🔗 **Smart Navigation** - Springt direkt zur richtigen Seite per URL  
🌐 **Cross-Platform** - Linux, macOS, WSL2, und Windows (nativ!)  

---

## 📋 Voraussetzungen

### 🪟 Windows (Nativ) - EMPFOHLEN! 🎉

**ALLES funktioniert jetzt 100% nativ auf Windows - INKLUSIVE OCR!**

**Automatisches Setup (nur 5 Minuten):**
```cmd
setup_windows.bat
```

Das war's! Das Script installiert automatisch:
- ✅ Python 3.11+ (via winget)
- ✅ Tesseract OCR mit deutschem Sprachpaket (via winget)
- ✅ Ghostscript für PDF-Optimierung (via winget)
- ✅ Alle Python-Pakete (via pip)
- ✅ Chromium Browser (via playwright)

**Voraussetzungen:**
- Windows 10 (1809+) oder Windows 11
- ~500 MB freier Speicherplatz
- Internetverbindung

📖 **Detaillierte Anleitung:**
- [Windows Native Setup Guide](docs/WINDOWS_NATIVE_SETUP.md) - Vollständige Dokumentation
- [Windows Quickstart](docs/WINDOWS_QUICKSTART.md) - 3-Schritt Schnellstart

**Kein WSL2 mehr nötig - alles läuft nativ!** 🚀

---

### 🐧 Linux / macOS / 🪟 WSL2

**Linux/WSL2:**
```bash
sudo apt update
sudo apt install -y \
    python3.12-venv \
    tesseract-ocr \
    tesseract-ocr-deu \
    ocrmypdf \
    qpdf \
    ghostscript \
    poppler-utils \
    libgbm1 \
    libdrm2 \
    mesa-vulkan-drivers
```

**macOS:**
```bash
brew install python tesseract tesseract-lang ocrmypdf
```

**WSL2-Nutzer:** Das Tool ist für WSL2 + WSLg optimiert! Siehe [WSL2 Configuration Guide](docs/WSL2_CONFIGURATION.md).

**Hinweis:** WSL2 ist nicht mehr nötig für Windows-Nutzer! Nutze stattdessen die native Windows-Version (siehe oben).

---

## 🚀 Schnellstart (5 Minuten)

### 1️⃣ Projekt herunterladen & Setup

**Linux / macOS / WSL2:**
```bash
# Python Virtual Environment erstellen
python3 -m venv .venv
source .venv/bin/activate

# Python-Pakete installieren
pip install -r requirements.txt

# Browser installieren
playwright install chromium

# System-Dependencies installieren (WSL2/Linux)
playwright install-deps chromium
```

**WSL2-Nutzer - Umgebung prüfen:**
```bash
./check_wsl_environment.sh  # Prüft WSL2-Konfiguration
python test_browser_config.py  # Testet Browser-Launch
```

**Windows (PowerShell/CMD):**
```cmd
REM Automatisches Setup (EMPFOHLEN):
setup_windows.bat

REM Oder manuell:
python -m venv .venv
.venv\Scripts\activate.bat
pip install -r requirements.txt
playwright install chromium

REM Tesseract OCR installieren:
winget install -e --id UB-Mannheim.TesseractOCR
```

**Das war's!** Setup ist fertig. OCR funktioniert jetzt auch nativ! 🎉

💡 **Tipp:** Nutze den neuen CLI: `python edubase_cli.py --help`

---

### 2️⃣ Screenshots erstellen

**Windows (EMPFOHLEN - nativ):**
```cmd
.\capture.bat
REM Oder mit PowerShell:
.\capture.ps1
REM Oder mit CLI für mehr Optionen:
python edubase_cli.py capture --book-url "URL" --pages NUM --delay-ms 1500
```

**Linux / macOS / WSL2:**
```bash
./capture.sh
# Oder mit CLI:
python edubase_cli.py capture --book-url "URL" --pages NUM
```

**Was passiert:**

1. 🌐 Browser öffnet sich mit Edubase
2. 🔑 Du loggst dich ein (nur beim ersten Mal - wird gespeichert)
3. ⚙️ Du stellst den Viewer ein (Zoom, Fit to page)
4. ✅ Du drückst Enter
5. 📸 396 Screenshots werden automatisch erstellt (~10-12 Minuten)

**Wichtig während Capture:**
- ❌ **NICHT** Browser-Fenster minimieren
- ❌ **NICHT** in den Browser klicken
- ✅ **OK** Terminal/andere Apps nutzen
- ✅ **OK** Kaffee holen ☕

---

### 3️⃣ PDF mit OCR erstellen

**Windows (NATIV - funktioniert perfekt!):**
```cmd
.\build.bat
REM Oder mit PowerShell:
.\build.ps1
REM Oder mit CLI für mehr Optionen:
python edubase_cli.py build --input ./input_pages --output ./output/book.pdf --lang deu
```

**Linux / macOS / WSL2:**
```bash
./build_pdf.sh
# Oder mit CLI:
python edubase_cli.py build --input ./input_pages --output ./output/book.pdf
```

**💡 Windows-Nutzer:** OCR funktioniert jetzt 100% nativ mit Tesseract! Kein WSL2 nötig.  
Siehe [Windows Native Setup](docs/WINDOWS_NATIVE_SETUP.md) für Details.

**Was passiert:**

1. 🖼️ Bilder werden vorverarbeitet & optimiert (Auto-Crop)
2. 📄 PDF wird aus den Screenshots erstellt
3. 🔤 Deutsche OCR-Texterkennung läuft (Tesseract)
4. 💾 Fertiges PDF wird gespeichert & optimiert

**Performance:**
- Linux/macOS: ~12-15 Minuten (396 Seiten)
- Windows Nativ: ~15-20 Minuten (396 Seiten)
- WSL2: ~12-15 Minuten (396 Seiten)

**Ergebnis:** `output/edubase_60505.pdf` - Vollständig durchsuchbar & optimiert!

---

## 📖 Ausführliche Anleitung

### Erster Start: Screenshots erstellen

```bash
./capture.sh
```

Der Script zeigt dir genau, was zu tun ist:

```
╔════════════════════════════════════════════════════════════════════╗
║  📸 EDUBASE TO PDF - SCREENSHOT CAPTURE                            ║
╚════════════════════════════════════════════════════════════════════╝

Buch:   https://app.edubase.ch/#doc/60505
Seiten: 396 Seiten
Dauer:  ~10-12 Minuten (1.5s pro Seite)

────────────────────────────────────────────────────────────────────

📋 SO FUNKTIONIERT'S:

  1. Browser öffnet sich automatisch mit Edubase
  2. Logge dich ein (falls nötig - wird gespeichert)
  3. Wichtig: Stelle im Viewer ein:
      • Ansicht: Fit to width oder Fit to page
      • Zoom: 100-120% (gut lesbar)
      • Keine Seitenleiste/Menüs im Weg
  4. Drücke Enter im Terminal → Capture startet
```

#### ⚙️ Viewer richtig einstellen

**Perfekte Einstellungen für beste Qualität:**

1. **Zoom/Ansicht:**
   - Nutze die Viewer-Controls oben
   - Wähle "Fit to width" oder "Fit to page"
   - Oder stelle manuell auf 100-120% Zoom

2. **Seitenleiste/Menüs:**
   - Schließe Navigation/Inhaltsverzeichnis
   - Nur das Buch sollte sichtbar sein

3. **Vollbild (optional):**
   - F11 für Vollbild = bessere Qualität
   - Aber nicht nötig

**Dann:** Drücke Enter im Terminal → Los geht's!

#### 📸 Während Capture läuft

Du siehst im Terminal:

```
[Page 1] Saved page_0001.png
[Page 2] Saved page_0002.png
[Page 3] Saved page_0003.png
...
```

**Status:**
- ✅ Screenshots landen in `input_pages/`
- ⏱️ 1.5 Sekunden Pause zwischen Seiten
- 🔄 Automatisches Weiterblättern mit Pfeiltaste

**Falls was schiefgeht:**
- `Ctrl+C` drücken → Capture stoppt
- Einfach `./capture.sh` nochmal ausführen
- Script fragt, ob du fortfahren willst

#### ✅ Capture fertig

```
╔════════════════════════════════════════════════════════════════════╗
║  ✓ CAPTURE ERFOLGREICH ABGESCHLOSSEN!                              ║
╚════════════════════════════════════════════════════════════════════╝

Ergebnis:
  📁 Ort:      ./input_pages/
  📄 Dateien:  98 Screenshots
  💾 Größe:    45M

➜ NÄCHSTER SCHRITT: PDF mit OCR erstellen

  Führe aus: ./build_pdf.sh
```

---

### PDF mit OCR erstellen

```bash
./build_pdf.sh
```

Der Script zeigt dir den Fortschritt:

```
╔════════════════════════════════════════════════════════════════════╗
║  📚 EDUBASE TO PDF - PDF BUILDER (OCR)                             ║
╚════════════════════════════════════════════════════════════════════╝

Eingabe:
  📁 Verzeichnis:  ./input_pages/
  📄 Screenshots:  98 Dateien
  💾 Größe:        45M

Ausgabe:
  📄 PDF:          ./output/edubase_60505.pdf
  🔤 OCR-Sprache:  Deutsch
  ⚙️  DPI:          300

────────────────────────────────────────────────────────────────────

📋 VERARBEITUNGSSCHRITTE:

  1. Bilder vorverarbeiten (Crop, JPEG-Konvertierung)
  2. PDF aus Bildern erstellen
  3. OCR-Texterkennung durchführen (Deutsch)
  4. PDF optimieren & Metadaten setzen

⏱️  Geschätzte Dauer: 3-5 Minuten (je nach CPU-Leistung)
```

#### 🔧 Was passiert im Detail

**1. Vorverarbeitung** (~2 Min)
```
Preprocessing: 100%|██████████| 396/396 [01:58<00:00, 3.34img/s]
```
- Bilder werden zugeschnitten (weiße Ränder weg)
- Konvertierung zu JPEG für kleinere Dateigröße
- Qualität bleibt hoch (92/100)

**2. PDF-Erstellung** (~30s)
- Alle Bilder werden zu einem PDF zusammengefügt
- DPI wird auf 300 gesetzt (druckqualität)

**3. OCR-Texterkennung** (~8-12 Min)
- Tesseract analysiert jede Seite
- Erkennt deutschen Text
- Macht das PDF durchsuchbar
- 6 parallele Jobs für Speed

**4. Optimierung** (~10s)
- PDF wird komprimiert
- Metadaten werden gesetzt (Titel, Autor)
- Finale Validierung

#### ✅ PDF fertig!

```
╔════════════════════════════════════════════════════════════════════╗
║  ✓ PDF ERFOLGREICH ERSTELLT!                                       ║
╚════════════════════════════════════════════════════════════════════╝

📊 ERGEBNIS:
  📄 Datei:     ./output/edubase_60505.pdf
  💾 Größe:     15M (15.8 MB)

✓ PDF-Informationen:
  📄 Seiten:    98
  📖 Titel:     Edubase Book 60505

✓ OCR-Text erfolgreich:
  Textauszug: Kapitel 1 Einleitung Dies ist ein Beispiel für...

────────────────────────────────────────────────────────────────────

🎉 FERTIG! Du kannst jetzt:

  1. PDF öffnen:
     xdg-open ./output/edubase_60505.pdf

  2. Im PDF suchen (Ctrl+F funktioniert!)

  3. Text markieren & kopieren

  4. Screenshots behalten für spätere Bearbeitung
     oder löschen: rm -rf ./input_pages/*.png

PDF jetzt öffnen? (j/n):
```

---

## 💡 Erweiterte Nutzung

### Andere Bücher exportieren

Bearbeite `capture.sh` und `build_pdf.sh`:

```bash
# In capture.sh Zeile 18-20 ändern:
BOOK_ID="DEINE_BUCH_ID"      # z.B. "12345"
PAGES=ANZAHL_SEITEN           # z.B. 250
BOOK_URL="https://app.edubase.ch/#doc/${BOOK_ID}/1"

# In build_pdf.sh Zeile 18-21 ändern:
OUTPUT_FILE="./output/DEIN_BUCH_NAME.pdf"
BOOK_TITLE="Dein Buchtitel"
BOOK_AUTHOR="Autor Name"
BOOK_ID="DEINE_BUCH_ID"
```

**Hinweis:** Das Tool nutzt direkte URL-Navigation zu Seiten:
- Seite 1: `https://app.edubase.ch/#doc/60505/1`
- Seite 100: `https://app.edubase.ch/#doc/60505/100`
- Seite 396: `https://app.edubase.ch/#doc/60505/396`

Dies macht den Capture schneller und zuverlässiger!

### Resume nach Unterbrechung

Falls Capture unterbrochen wurde:

```bash
./capture.sh
```

Der Script fragt:
```
⚠️  Es existieren bereits 45 Screenshots in ./input_pages

Möchtest du:
  [1] Von vorne anfangen (löscht alte Screenshots)
  [2] Fortfahren (überspringt existierende Seiten)
  [3] Abbrechen
```

Wähle **[2]** zum Fortfahren ab Seite 46.

### Verschiedene Bücher parallel

Erstelle separate Ordner:

```bash
mkdir -p buch1/input_pages buch1/output
mkdir -p buch2/input_pages buch2/output

# Kopiere Scripts und passe Pfade an
cp capture.sh buch1/
cp build_pdf.sh buch1/
# ... bearbeite BOOK_URL, PAGES etc.
```

---

## 🔧 Konfiguration & Tweaking

### Screenshot-Qualität erhöhen

In `capture.sh` Zeile 107:

```bash
--delay-ms 2000        # Längere Pause = Seiten laden besser
```

### OCR-Sprache ändern

In `build_pdf.sh` Zeile 89:

```bash
--lang deu+eng         # Deutsch + Englisch
--lang eng             # Nur Englisch
```

### JPEG-Qualität anpassen

In `build_pdf.sh` Zeile 93:

```bash
--jpeg-quality 95      # Höhere Qualität = größere Datei
--jpeg-quality 85      # Kleinere Datei = etwas weniger Qualität
```

### Auto-Crop deaktivieren

Falls zu viel weggeschnitten wird:

```bash
# In capture.sh Zeile 109 entfernen:
--crop --crop-threshold 248 --crop-margin 10

# Oder Threshold anpassen (248 = sehr weiß):
--crop --crop-threshold 240 --crop-margin 20
```

---

## 🐛 Troubleshooting

### ❌ "Virtual Environment nicht gefunden"

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### ❌ "Playwright Browser fehlt"

```bash
source .venv/bin/activate
playwright install chromium
```

### ❌ Browser startet nicht / Fehler beim Start

Installiere System-Dependencies:

```bash
sudo apt install -y \
    libglib2.0-0 libnss3 libnspr4 libdbus-1-3 \
    libatk1.0-0 libatk-bridge2.0-0 libcups2 \
    libdrm2 libxkbcommon0 libxcomposite1 \
    libxdamage1 libxfixes3 libxrandr2 libgbm1 \
    libpango-1.0-0 libcairo2 libasound2
```

### ❌ "Keine Screenshots gefunden"

Prüfe:

```bash
ls -lh input_pages/
```

Falls leer: `./capture.sh` nochmal ausführen.

### ❌ OCR schlägt fehl

```bash
# Prüfe ob Tesseract installiert ist:
tesseract --version

# Falls nicht:
sudo apt install tesseract-ocr tesseract-ocr-deu

# Prüfe ob ocrmypdf installiert ist:
ocrmypdf --version

# Falls nicht:
sudo apt install ocrmypdf
```

### ❌ Screenshots haben falsche Größe

Stelle im Edubase-Viewer:
- "Fit to width" oder "Fit to page"
- Zoom 100-120%
- Keine Seitenleiste sichtbar

Dann `./capture.sh` neu starten.

### ❌ Browser-Fenster flackert / springt

Normal! Das passiert beim Screenshot + Weiterblättern.  
**NICHT** in den Browser klicken während Capture läuft.

### ❌ PDF-Datei zu groß

Reduziere JPEG-Qualität in `build_pdf.sh`:

```bash
--jpeg-quality 85      # Statt 92
--optimize 3           # Statt 2 (max. Kompression)
```

### ❌ OCR-Text ungenau

Erhöhe Screenshot-Qualität:
- Höheren Zoom im Viewer (120%)
- Längere Delay: `--delay-ms 2000`
- Höhere JPEG-Qualität: `--jpeg-quality 95`

---

## 📊 Performance & Benchmarks

**Getestet auf:**
- CPU: AMD Ryzen 5 / Intel i5 äquivalent
- RAM: 8 GB
- OS: Ubuntu 24.04 / WSL2

**Zeiten für 396 Seiten:**

| Phase           | Dauer     | CPU-Last |
|-----------------|-----------|----------|
| Capture         | ~10 Min   | Niedrig  |
| Preprocessing   | ~2 Min    | Mittel   |
| OCR (6 Jobs)    | ~12 Min   | Hoch     |
| Optimierung     | ~30s      | Mittel   |
| **GESAMT**      | **~25 Min**| -       |

**Dateigröße Beispiel:**
- Screenshots (396x PNG): ~180 MB
- Finales PDF mit OCR: ~60 MB
- Ratio: 3:1 Kompression

---

## 🔒 Rechtliche Hinweise

**⚠️ WICHTIG - Bitte beachten:**

Dieses Tool wird unter der MIT-Lizenz mit erweiterten Nutzungsbedingungen bereitgestellt.
Siehe [LICENSE](LICENSE) für vollständige Details.

### Deine Verantwortung als Nutzer

✅ **Du bist selbst verantwortlich für:**
- Einhaltung aller Gesetze und Vorschriften
- Einhaltung der Edubase-Nutzungsbedingungen
- Sicherstellung, dass du Rechte an den Inhalten hast
- Rechtmäßige Verwendung des Tools und der PDFs
- Alle Folgen aus der Nutzung dieses Tools

✅ **Erlaubte Nutzung:**
- Persönliche Studiennutzung
- Private Kopien von selbst lizenzierten Inhalten
- Eigener Edubase-Account mit gültiger Lizenz
- Offline-Nutzung für eigene Zwecke

❌ **Nicht erlaubt:**
- Weitergabe oder Verkauf der PDFs
- Umgehen von DRM oder technischen Schutzmaßnahmen
- Massendownload ohne Berechtigung
- Kommerzielle Nutzung ohne Lizenz
- Verletzung von Urheberrechten
- Verstöße gegen Edubase-Nutzungsbedingungen

### Haftungsausschluss

- Die Entwickler übernehmen **KEINE HAFTUNG** für rechtliche Konsequenzen
- Du verwendest dieses Tool **AUF EIGENES RISIKO**
- Keine Garantie für Rechtmäßigkeit in deiner Jurisdiktion
- Dieses Tool ist **NICHT** von Edubase autorisiert oder unterstützt

### Faire Nutzung

**Dieses Tool:**
- Nutzt deinen eigenen Browser & Login
- Respektiert Rate-Limits (1.5s/Seite)
- Simuliert normales manuelles Blättern
- Keine Automatisierung zum Umgehen von Schutzmaßnahmen

**Bei Unsicherheit:**
- Konsultiere einen Rechtsanwalt
- Lies die Edubase-Nutzungsbedingungen
- Prüfe deine Lizenzrechte

**Durch die Nutzung dieses Tools erklärst du dich mit allen Bedingungen in der [LICENSE](LICENSE)-Datei einverstanden.**

---

## 📁 Projektstruktur

```
edubase-exporter/
│
├── 📄 Core Files
│   ├── edubase_to_pdf.py         ← Legacy Python-Script
│   ├── edubase_cli.py            ← Neuer CLI (empfohlen)
│   ├── capture.sh / capture.bat  ← Schritt 1: Screenshots (Linux/Windows)
│   ├── build_pdf.sh / build.bat  ← Schritt 2: PDF mit OCR (Linux/Windows)
│   ├── capture.ps1 / build.ps1   ← PowerShell-Varianten
│   ├── setup_windows.bat         ← 🪟 Automatisches Windows-Setup (NEU!)
│   ├── requirements.txt          ← Python-Dependencies
│   ├── Makefile                  ← Convenience commands (make help)
│   └── pytest.ini                ← Test configuration
│
├── 📁 Documentation
│   ├── README.md                          ← Diese Datei (Hauptdoku)
│   ├── QUICKSTART.md                      ← 3-Schritt Schnellstart
│   ├── LICENSE                            ← Lizenz & Nutzungsbedingungen
│   ├── WINDOWS_NATIVE_IMPLEMENTATION.md   ← 🪟 Tech Details (NEU!)
│   ├── WINDOWS_NATIVE_SUMMARY.md          ← 🪟 Zusammenfassung (NEU!)
│   └── docs/
│       ├── WINDOWS_NATIVE_SETUP.md        ← 🪟 Windows Vollständige Anleitung (NEU!)
│       ├── WINDOWS_QUICKSTART.md          ← 🪟 Windows 3-Schritt Guide (NEU!)
│       ├── WSL2_CONFIGURATION.md          ← WSL2 Setup (optional)
│       ├── TUTORIAL.md                    ← Visuelles Setup-Tutorial
│       └── PROJECT_OVERVIEW.md            ← Technische Struktur
│
├── 📁 Tests
│   ├── test_browser_config.py        ← Browser-Test
│   └── tests/
│       ├── test_edubase_to_pdf.py    ← Unit tests
│       ├── conftest.py               ← Pytest config
│       └── README.md                 ← Test documentation
│
├── 📁 Data Directories
│   ├── input_pages/                  ← Screenshots landen hier
│   ├── output/                       ← Fertige PDFs hier
│   └── .venv/                        ← Python Virtual Environment
│
└── 📁 Configuration
    ├── .gitignore                    ← Git Ignore Rules
    └── .pw_edubase/                  ← Browser-Profil (auto-erstellt)
```

**🪟 Windows-Nutzer:** Alle Scripts sind optimiert für native Windows-Nutzung!
- `.bat` files für Command Prompt
- `.ps1` files für PowerShell
- `setup_windows.bat` für automatische Installation

---

## 🧪 Testing

### Run tests:
```bash
make test
```

### With coverage report:
```bash
make coverage
```

### Manual test run:
```bash
pytest tests/ -v
```

---

## 🆘 Support & Fragen

### Logs anschauen

Alle Ausgaben werden im Terminal angezeigt. Bei Fehlern:

1. Scrolle hoch im Terminal
2. Suche nach `ERROR` oder `Traceback`
3. Poste relevante Zeilen in deine Anfrage

### Häufige Fragen

**Q: Kann ich mehrere Bücher parallel verarbeiten?**  
A: Nein, lasse immer nur einen Capture/Build laufen. Sonst Konflikte.

**Q: Werden meine Login-Daten gespeichert?**  
A: Ja, im Browser-Profil unter `~/.pw_edubase/` (Linux/macOS) oder im User-Verzeichnis (Windows). Lokal, sicher, nicht geteilt.

**Q: Kann ich PDFs für Tablet optimieren?**  
A: Ja! Nutze `--dpi 200` statt 300 für kleinere Dateigröße und schnellere Verarbeitung.

**Q: OCR dauert ewig, kann ich beschleunigen?**  
A: Ja, erhöhe `--jobs 8` (oder bis zu Anzahl CPU-Kerne) für schnellere Verarbeitung.

**Q: Funktioniert es auch mit Windows?**  
A: **Ja, perfekt!** Alles funktioniert jetzt 100% nativ auf Windows - **INKLUSIVE OCR mit deutschem Tesseract!**  
   - ✅ Automatisches Setup mit `setup_windows.bat`
   - ✅ Alle Features funktionieren nativ
   - ✅ KEIN WSL2 nötig!
   - 📖 Siehe [Windows Native Setup Guide](docs/WINDOWS_NATIVE_SETUP.md) und [Windows Quickstart](docs/WINDOWS_QUICKSTART.md)

**Q: Welches System soll ich nutzen - Windows nativ oder WSL2?**  
A: **Windows Nativ für 95% der Nutzer!**
   - ✅ Einfacheres Setup (5 Min statt 30 Min)
   - ✅ Keine Linux-Kenntnisse nötig
   - ✅ Volle Funktionalität
   - ⚠️ Nur ~15% langsamer bei OCR
   
   WSL2 nur wenn du bereits WSL2 nutzt oder maximale Performance brauchst.

**Q: Kann ich die Screenshots behalten?**  
A: Ja! Lass `input_pages/` einfach da für spätere Nutzung oder andere PDF-Konfigurationen.

---

## 🎓 Tipps für beste Ergebnisse

### ⭐ Windows-spezifische Tipps

**Für beste Performance auf Windows:**

1. **Antivirus temporär ausschalten:** Manche AV-Programme können Browser-Automation stören
2. **Energiesparplan:** Auf "Höchstleistung" stellen für schnellere OCR
3. **Mehr CPU-Kerne:** `--jobs 8` nutzen wenn verfügbar
4. **Terminal nach Installation neu öffnen:** Damit PATH-Änderungen wirksam werden

**Tesseract-Sprachen:**
- Deutsch ist bereits enthalten (via `setup_windows.bat`)
- Weitere Sprachen: Download von https://github.com/tesseract-ocr/tessdata
- Kopiere `.traineddata` nach `C:\Program Files\Tesseract-OCR\tessdata\`
- Nutze mit `--lang deu+eng` für mehrsprachige PDFs

📖 Mehr Windows-Tipps: [Windows Native Setup Guide](docs/WINDOWS_NATIVE_SETUP.md)

---

### ⭐ Screenshot-Qualität maximieren

1. **Viewer-Zoom:** 120% = größere Schrift = bessere OCR
2. **Vollbild:** F11 drücken = mehr Platz = weniger Crop nötig
3. **Seitenleiste weg:** Navigation schließen = nur Inhalt
4. **Längere Delays:** Bei langsamem Internet: `--delay-ms 2500`

### ⭐ OCR-Genauigkeit erhöhen

1. **Deskew aktiviert:** `--deskew` (schon default)
2. **Höhere DPI:** `--dpi 300` (schon default)
3. **Crop-Margin größer:** `--crop-margin 20` statt 10
4. **Mehrsprachig:** `--lang deu+eng` für Mischtext

### ⭐ Dateigröße reduzieren

1. **Niedrigere JPEG-Qualität:** `--jpeg-quality 85`
2. **Mehr Optimierung:** `--optimize 3`
3. **Niedrigere DPI:** `--dpi 200` (OK für Bildschirm)

### ⭐ Zeit sparen

1. **Mehr OCR-Jobs:** `--jobs 8` (wenn CPU hat)
2. **Kürzere Delays:** `--delay-ms 1000` (wenn stabil)
3. **Kein Deskew:** Weglassen falls Seiten gerade (spart Zeit)

---

## 📝 Changelog

### Version 1.1 (2024-10-30)
- 🪟 **Windows Native Support!** - 100% native Windows-Unterstützung
- ✨ Automatisches Setup-Script `setup_windows.bat`
- 🔤 OCR funktioniert vollständig nativ auf Windows (Tesseract + OCRmyPDF)
- 📖 Neue Windows-Dokumentation (WINDOWS_NATIVE_SETUP.md + WINDOWS_QUICKSTART.md)
- 🔧 Verbesserte `.bat` und `.ps1` Scripts
- ⚡ Kein WSL2 mehr nötig für Windows-Nutzer!

### Version 1.0 (2024-10-23)
- ✨ Initiales Release
- 🎨 Farbige, benutzerfreundliche CLI
- 📸 Automatischer Screenshot-Capture
- 🔤 Deutsche OCR-Texterkennung
- 📚 PDF/A Support
- ✂️ Auto-Crop Funktion
- 🔄 Resume-Funktion nach Unterbrechung

---

**🎉 Viel Erfolg mit deinem durchsuchbaren PDF!**

Bei Fragen oder Problemen: 
- **Windows:** Siehe [Windows Native Setup Guide](docs/WINDOWS_NATIVE_SETUP.md)
- **Allgemein:** Schau ins Troubleshooting oder erstelle ein GitHub Issue
