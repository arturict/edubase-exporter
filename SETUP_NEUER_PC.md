# 📦 EDUBASE-EXPORTER AUF NEUEM PC EINRICHTEN

## Voraussetzungen

- **Ubuntu/Linux** (kein Windows, kein WSL)
- **Internet-Verbindung**
- **Git** installiert

---

## 🚀 INSTALLATION - SCHRITT FÜR SCHRITT

### 1️⃣ Repository klonen

```bash
cd ~
git clone https://github.com/arturict/edubase-exporter.git
cd edubase-exporter
```

### 2️⃣ Setup-Script ausführen

```bash
bash setup.sh
```

**Was passiert:**
- ✅ Prüft Python 3
- ✅ Installiert System-Dependencies (tesseract, ocrmypdf, ghostscript)
- ✅ Erstellt Python Virtual Environment
- ✅ Installiert Python-Pakete (playwright, pillow, etc.)
- ✅ Installiert Firefox Browser für Playwright

**Dauer:** ~5-10 Minuten (je nach Internet-Geschwindigkeit)

### 3️⃣ Fertig! ✅

Das wars! Du kannst jetzt loslegen.

---

## 📸 NUTZUNG

### Schnellstart

```bash
./capture.sh
```

**Was passiert:**
1. Firefox öffnet sich
2. Du loggst dich in Edubase ein
3. Du stellst den PDF-Viewer ein (Zoom, Ansicht)
4. Du drückst Enter → Screenshots werden gemacht

### PDF erstellen

```bash
./build_pdf.sh
```

**Was passiert:**
- Nimmt alle Screenshots aus `input_pages/`
- Erstellt durchsuchbares PDF mit OCR (Deutsch)
- Speichert in `output/`

---

## ⚙️ KONFIGURATION

### capture.sh anpassen

Öffne `capture.sh` und ändere:

```bash
BOOK_ID="60505"      # Deine Buch-ID
PAGES=396            # Anzahl Seiten
```

**Buch-ID finden:**
- URL: `https://app.edubase.ch/#doc/60505`
- ID: `60505` (die Nummer in der URL)

---

## 🔧 WICHTIGE BEFEHLE

### Updates holen

```bash
cd ~/edubase-exporter
git pull
```

### Virtual Environment aktivieren

```bash
source .venv/bin/activate
```

### Browser neu installieren

```bash
source .venv/bin/activate
playwright install firefox
playwright install-deps firefox
```

---

## 📁 VERZEICHNISSTRUKTUR

```
edubase-exporter/
├── capture.sh           # Screenshots erstellen
├── build_pdf.sh         # PDF mit OCR erstellen
├── setup.sh             # Einrichtung (einmal ausführen)
├── edubase_cli.py       # Haupt-Script
├── input_pages/         # Screenshots (werden hier gespeichert)
├── output/              # Fertige PDFs
└── .venv/               # Python Virtual Environment
```

---

## 🐛 PROBLEME LÖSEN

### "Firefox not found"

```bash
source .venv/bin/activate
playwright install firefox
```

### "Permission denied"

```bash
chmod +x capture.sh build_pdf.sh setup.sh
```

### "tesseract not found"

```bash
sudo apt update
sudo apt install tesseract-ocr tesseract-ocr-deu
```

### Python-Fehler

```bash
rm -rf .venv
bash setup.sh
```

---

## 💡 TIPPS

### Mehrere Bücher

Erstelle für jedes Buch einen eigenen Branch:

```bash
git checkout -b buch-mathe
# Ändere BOOK_ID in capture.sh
# Capture + Build
git add input_pages/ output/
git commit -m "Mathe-Buch fertig"
```

### Parallele Nutzung

Du kannst mehrere Terminals öffnen:
- Terminal 1: capture.sh läuft
- Terminal 2: Schon build_pdf.sh für vorheriges Buch

### Screenshots löschen

Nach erfolgreichem PDF:

```bash
rm -rf input_pages/*.png
```

---

## 🔄 WORKFLOW

```
1. git clone (einmalig auf neuem PC)
2. bash setup.sh (einmalig)
3. Editiere capture.sh (BOOK_ID + PAGES)
4. ./capture.sh (Screenshots machen)
5. ./build_pdf.sh (PDF erstellen)
6. Fertig! → PDF in output/
```

---

## 🆘 SUPPORT

Bei Problemen:
1. Schaue in `README.md`
2. Prüfe Git Issues auf GitHub
3. Logs checken: `./capture.sh 2>&1 | tee capture.log`

---

## ✅ CHECKLISTE NEUER PC

- [ ] Ubuntu/Linux läuft
- [ ] Git installiert: `git --version`
- [ ] Python 3 installiert: `python3 --version`
- [ ] Repository geklont: `git clone ...`
- [ ] Setup ausgeführt: `bash setup.sh`
- [ ] Firefox installiert: `playwright install firefox`
- [ ] capture.sh ausführbar: `chmod +x capture.sh`
- [ ] Erster Test: `./capture.sh` startet Firefox
- [ ] Fertig! 🎉

