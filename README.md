# 📚 Edubase to PDF Exporter

**Erstelle durchsuchbare PDFs aus Edubase-Büchern mit nur 2 einfachen Befehlen.**

Dieses Tool macht Screenshots von deinem Edubase-Buch und wandelt sie in ein durchsuchbares PDF mit deutscher OCR-Texterkennung um.

## 🐧 **Ubuntu/Linux Only**

**Dieses Tool läuft optimal auf Ubuntu und anderen Linux-Systemen.**

```bash
# Automatisches Setup:
bash setup.sh

# Screenshots erstellen:
./capture.sh

# PDF mit OCR erstellen:
./build_pdf.sh

# Fertig! 🎉
```

---

**⚠️ WICHTIGER HINWEIS:** Du bist selbst verantwortlich für die rechtmäßige Nutzung dieses Tools. Siehe [LICENSE](LICENSE) für Details.

---

## 🎯 Features

✨ **Super einfach** - Nur 2 Befehle: `./capture.sh` → `./build_pdf.sh`  
🐧 **Ubuntu/Linux optimiert** - Automatisches Setup mit `setup.sh`  
🔐 **Sicherer Login** - Einmalig einloggen, danach automatisch wiederverwendet  
�� **Durchsuchbar** - Vollständige OCR-Texterkennung auf Deutsch  
✂️ **Auto-Crop** - Entfernt automatisch weiße Ränder  
📊 **Fortschritt** - Zeigt genau, was gerade passiert  
⚡ **Schnell** - 396 Seiten in ~10-12 Minuten Screenshots, ~15-20 Min OCR  
🔗 **Smart Navigation** - Springt direkt zur richtigen Seite per URL  
📖 **Stabile Rendering** - Playwright mit optimierten Centering-Einstellungen  

---

## 📋 Voraussetzungen

### 🐧 Ubuntu/Linux

**Automatisches Setup (nur 5 Minuten):**
```bash
bash setup.sh
```

Das Script installiert automatisch:
- ✅ Python 3.8+ mit Virtual Environment
- ✅ Tesseract OCR mit deutschem Sprachpaket
- ✅ Ghostscript für PDF-Optimierung
- ✅ Alle Python-Pakete (Playwright, img2pdf, etc.)
- ✅ Chromium Browser

**Voraussetzungen:**
- Ubuntu 18.04+ oder Debian 9+
- ~500 MB freier Speicherplatz
- Internetverbindung

---

## 🚀 Schnellstart

### 1. Setup (einmalig)

```bash
bash setup.sh
```

Das Script wird:
1. Python Virtual Environment erstellen
2. System-Pakete installieren (mit `sudo`)
3. Python-Abhängigkeiten installieren
4. Playwright Chromium-Browser installieren

**Dauer:** ~5-10 Minuten (abhängig von Internetverbindung)

### 2. Browser konfigurieren

Bevor du den Capture startest, musst du Folgendes vorbereiten:

```bash
# Book ID in capture.sh setzen
nano capture.sh
# Ändere BOOK_ID und PAGES
```

Beispiel:
```bash
BOOK_ID="60505"      # Deine Buch-ID (aus URL)
PAGES=396            # Gesamtzahl der Seiten
```

### 3. Screenshots erstellen

```bash
./capture.sh
```

Das Script wird:
1. ✅ Den Browser mit Edubase öffnen
2. ✅ Dich auffordern, dich einzuloggen (wird dann gespeichert!)
3. ✅ Den Viewer einzustellen (Zoom, Ansicht)
4. ✅ Enter zum Starten drücken
5. ✅ Automatisch alle Seiten screenshooten

**Dauer:** ~10-12 Minuten bei 396 Seiten

**Tips:**
- Der Browser-Login wird gespeichert - beim nächsten Mal geht's schneller!
- Stelle den Viewer auf "Fit to page" oder "Fit to width"
- Zoom: 100-120% ist ideal
- Keine Seitenleiste oder Menüs sollten sichtbar sein

### 4. PDF mit OCR erstellen

```bash
./build_pdf.sh
```

Das Script wird:
1. ✅ Alle Screenshots zu einem PDF zusammenfügen
2. ✅ Deutsche Texterkennung (OCR) durchführen
3. ✅ PDF durchsuchbar machen
4. ✅ Metadaten setzen

**Dauer:** ~15-25 Minuten bei 396 Seiten (abhängig von CPU)

**Output:** `output/book_final.pdf` ✅

---

## ⚙️ Erweiterte Optionen

### capture.sh Parameter

```bash
# Im capture.sh kannst du die folgenden Parameter anpassen:
BOOK_ID="60505"              # Buch-ID aus der Edubase URL
PAGES=396                    # Gesamtzahl der Seiten
OUT_DIR="./input_pages"      # Wo sollen Screenshots gespeichert werden?
BOOK_URL="..."               # Komplette Edubase URL

# delay-ms: Wartezeit zwischen Seiten in Millisekunden
# --crop: Weiße Ränder automatisch entfernen
```

### build_pdf.sh Parameter

```bash
# Im build_pdf.sh kannst du die folgenden Parameter anpassen:
INPUT_DIR="./input_pages"           # Wo sind die Screenshots?
OUTPUT_PDF="./output/book_final.pdf" # Wo soll das PDF gespeichert werden?

# --jobs: Anzahl paralleler OCR-Prozesse (Standard: 6)
# --optimize: Optimierungslevel 0-3 (Standard: 2)
# --jpeg-quality: JPEG-Qualität 80-95 (Standard: 92)
# --crop: Weiße Ränder entfernen vor PDF-Erstellung
```

---

## 📖 Tipps & Tricks

### Login-Problem?

Der Browser speichert deinen Login automatisch in `~/.edubase_browser`. Wenn du dich neu anmelden möchtest:

```bash
rm -rf ~/.edubase_browser
./capture.sh
```

### Nur bestimmte Seiten?

Um z.B. nur Seite 50-100 zu screenshooten:

```bash
python3 edubase_cli.py capture \
    --book-url "https://app.edubase.ch/#doc/60505/1" \
    --pages 396 \
    --start-index 50 \
    --delay-ms 1500 \
    --crop
```

### Rendering-Probleme?

Falls Seiten nicht korrekt zentriert werden:

1. Überprüfe die Browser-Ansicht:
   - Stelle "Fit to page" statt "Fit to width" ein
   - Zoom sollte 100-120% sein
   - Keine Sidebars sollten sichtbar sein

2. Erhöhe die Wartezeit:
   ```bash
   ./capture.sh  # wird mit erhöhten Delays laufen
   ```

---

## 🔧 Technische Details

### Architektur

1. **Playwright** - Screenshot-Engine
2. **PIL/Pillow** - Bildverarbeitung & Auto-Crop
3. **img2pdf** - Bild→PDF Konvertierung
4. **ocrmypdf** + **Tesseract** - Deutsche OCR
5. **pikepdf** - PDF-Metadaten-Management

### Rendering-Optimierungen

Das Tool wurde speziell für Ubuntu optimiert mit:
- ✅ Viewport-Centering für korrekte Buch-Darstellung
- ✅ Erhöhte Rendering-Wartezeiten für Stabilität
- ✅ Automated scrolling zum Zentrieren des Inhalts
- ✅ Network-Idle Wartelogik für vollständiges Laden

---

## 🐛 Troubleshooting

### "Python 3 not found"

```bash
sudo apt install python3 python3-venv python3-pip
```

### "tesseract: command not found"

```bash
sudo apt install tesseract-ocr tesseract-ocr-deu
```

### "ocrmypdf: command not found"

```bash
sudo apt install ocrmypdf
```

### Screenshots sind leer oder falsch

1. Überprüfe die Browser-Einstellungen im Viewer
2. Stelle sicher, dass keine Pop-ups im Weg sind
3. Führe mit `--start-index 1 --pages 3` nur 3 Seiten aus zum Testen

### Playwright Chromium-Fehler

```bash
playwright install chromium
playwright install-deps chromium
```

---

## 📊 Performance

**Hardware-Anforderungen (minimal):**
- CPU: 2 Kerne
- RAM: 2 GB
- Storage: 500 MB
- Internet: DSL oder besser

**Erwartete Laufzeiten (396 Seiten):**
- Screenshots: 10-12 Minuten
- OCR: 15-25 Minuten
- **Gesamt: 25-37 Minuten**

**Mit schneller Hardware (4+ Kerne, 8+ GB RAM):**
- Screenshots: 8-10 Minuten
- OCR: 10-15 Minuten  
- **Gesamt: 18-25 Minuten**

---

## 📄 Lizenz

Dieses Projekt steht unter der [LICENSE](LICENSE) Lizenz.

**Wichtig:** Du nutzt dieses Tool auf eigene Verantwortung. Stelle sicher, dass du berechtigt bist, die Inhalte zu extrahieren.

---

## 🤝 Contributing

Contributions sind willkommen! Bitte schau in [CONTRIBUTING.md](CONTRIBUTING.md) für Details.

---

## 📞 Support

Bei Problemen:

1. Überprüfe [Troubleshooting](#troubleshooting)
2. Schaue in [CONTRIBUTING.md](CONTRIBUTING.md)
3. Öffne ein Issue auf GitHub

---

**Viel Erfolg! 🎉**
