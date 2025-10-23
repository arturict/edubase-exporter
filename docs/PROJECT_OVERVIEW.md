# 📁 Projekt-Übersicht - Edubase to PDF Exporter

**Status:** ✅ Produktionsbereit  
**Version:** 1.0  
**Zweck:** Durchsuchbare PDFs aus Edubase-Büchern erstellen

---

## 🗂️ Dateistruktur

```
edubase-exporter/
│
├── �� Dokumentation (LESEN ZUERST!)
│   ├── QUICKSTART.md        ← ⭐ START HIER! Schnelleinstieg
│   ├── README.md             ← Vollständige Dokumentation
│   ├── TUTORIAL.md           ← Viewer-Setup visuell erklärt
│   └── PROJECT_OVERVIEW.md   ← Diese Datei
│
├── 🚀 Ausführbare Scripts (DIESE NUTZEN!)
│   ├── capture.sh            ← Schritt 1: Screenshots erstellen
│   └── build_pdf.sh          ← Schritt 2: PDF mit OCR bauen
│
├── 🐍 Python-Code (nicht direkt aufrufen)
│   ├── edubase_to_pdf.py     ← Haupt-Script (via Shell-Scripts)
│   └── requirements.txt      ← Python-Abhängigkeiten
│
├── 📁 Daten-Verzeichnisse
│   ├── input_pages/          ← Screenshots landen hier
│   │   └── .gitkeep
│   ├── output/               ← Fertige PDFs hier
│   │   └── .gitkeep
│   └── .venv/                ← Python Virtual Environment
│
└── ⚙️ Konfiguration
    └── .gitignore            ← Git Ignore Rules
```

---

## 🎯 Was macht welche Datei?

### 📘 Dokumentation

| Datei | Zweck | Wann lesen? |
|-------|-------|-------------|
| `QUICKSTART.md` | 3-Schritt-Anleitung | Sofort beim ersten Mal |
| `README.md` | Vollständige Doku | Bei Problemen / erweiterte Nutzung |
| `TUTORIAL.md` | Viewer-Setup visuell | Falls Screenshots schlecht |
| `PROJECT_OVERVIEW.md` | Projekt-Struktur | Zum Verständnis |

### 🚀 Executable Scripts

| Script | Input | Output | Dauer |
|--------|-------|--------|-------|
| `capture.sh` | Browser + Login | `input_pages/*.png` | ~3 Min |
| `build_pdf.sh` | `input_pages/*.png` | `output/*.pdf` | ~4 Min |

### 🐍 Python Code

| Datei | Zweck | Direkt nutzen? |
|-------|-------|----------------|
| `edubase_to_pdf.py` | Hauptlogik | ❌ Nutze Shell-Scripts |
| `requirements.txt` | Dependencies | Nur für `pip install` |

---

## 🔄 Typischer Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    ERSTER START                             │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
            ┌──────────────────────────┐
            │  1. Setup ausführen      │
            │     (siehe QUICKSTART)   │
            │  • venv erstellen        │
            │  • pip install           │
            │  • playwright install    │
            └──────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  NORMALER WORKFLOW                          │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
            ┌──────────────────────────┐
            │  2. ./capture.sh         │
            │  • Browser öffnet sich   │
            │  • Einloggen             │
            │  • Viewer einstellen     │
            │  • Enter drücken         │
            │  → 98 Screenshots        │
            └──────────────────────────┘
                           │
                           ▼
            ┌──────────────────────────┐
            │  3. ./build_pdf.sh       │
            │  • Bilder vorverarbeiten │
            │  • PDF erstellen         │
            │  • OCR durchführen       │
            │  → Fertiges PDF!         │
            └──────────────────────────┘
                           │
                           ▼
            ┌──────────────────────────┐
            │  4. PDF nutzen           │
            │  • Durchsuchen (Ctrl+F)  │
            │  • Text kopieren         │
            │  • Offline lesen         │
            └──────────────────────────┘
```

---

## 📊 Datenfluss

```
Edubase Website
       │
       │ [Browser + Playwright]
       ▼
Screenshots (PNG)
input_pages/page_0001.png
input_pages/page_0002.png
...
input_pages/page_0098.png
       │
       │ [Preprocessing: Crop + JPEG]
       ▼
Optimierte Bilder (JPEG)
/tmp/tmpXXXXXX/processed/*.jpg
       │
       │ [img2pdf]
       ▼
Rohes PDF
/tmp/tmpXXXXXX/raw.pdf
       │
       │ [Tesseract OCR Deutsch]
       ▼
OCR PDF
/tmp/tmpXXXXXX/ocr.pdf
       │
       │ [Metadaten + Optimierung]
       ▼
Finales PDF
output/edubase_60505.pdf
```

---

## 🎨 UX-Features

### ✨ Farbige, benutzerfreundliche CLI

- 🟢 **Grün:** Erfolgs-Meldungen
- 🔵 **Blau:** Informationen / Trennlinien
- 🟡 **Gelb:** Warnungen / Wichtige Hinweise
- 🔴 **Rot:** Fehler
- **Fett:** Wichtige Begriffe / Befehle

### 📋 Klare Schritt-für-Schritt-Anweisungen

Jeder Script zeigt:
1. Was wird gemacht?
2. Was ist zu tun?
3. Wie lange dauert es?
4. Was ist das Ergebnis?

### 🔄 Resume-Funktion

Falls unterbrochen:
- Script erkennt existierende Screenshots
- Fragt, ob neu starten oder fortfahren
- Spart Zeit bei großen Büchern

### ✅ Validierung & Feedback

- Zeigt Dateigrößen
- Zählt verarbeitete Seiten
- Testet OCR-Qualität
- Bietet PDF direkt zu öffnen

---

## ��️ Technologie-Stack

| Komponente | Tool | Zweck |
|------------|------|-------|
| **Browser-Automation** | Playwright | Screenshot-Capture |
| **Bildverarbeitung** | Pillow (PIL) | Crop, Resize, Format-Konvertierung |
| **PDF-Erstellung** | img2pdf | Bilder → PDF |
| **OCR** | Tesseract + ocrmypdf | Text-Erkennung Deutsch |
| **PDF-Manipulation** | pikepdf | Metadaten setzen |
| **CLI-Fortschritt** | tqdm | Progress Bars |
| **Shell-Scripts** | Bash | User-Interface |

---

## 📈 Performance-Metriken

### Capture-Phase (98 Seiten)
- **Dauer:** ~2.5 Minuten
- **CPU-Last:** Niedrig (15-25%)
- **RAM:** ~500 MB (Browser)
- **Disk I/O:** Moderat (PNG-Schreibvorgänge)
- **Netzwerk:** Minimal (nur Seitenlade)

### Build-Phase (98 Seiten)
- **Dauer:** ~4 Minuten
- **CPU-Last:** Hoch (80-100% während OCR)
- **RAM:** ~1.5 GB (Tesseract)
- **Disk I/O:** Hoch (Temp-Dateien)
- **Netzwerk:** Keine

### Gesamt
- **Ende-zu-Ende:** ~6-7 Minuten
- **Eingabe:** 0 Bytes (Webseite)
- **Temp-Daten:** ~45 MB (Screenshots)
- **Ausgabe:** ~15 MB (PDF mit OCR)

---

## 🔐 Sicherheit & Datenschutz

### Was wird gespeichert?

| Ort | Inhalt | Sensibel? |
|-----|--------|-----------|
| `~/.pw_edubase/` | Browser-Profil + Cookies | ✅ Ja (Login) |
| `input_pages/` | Screenshot-Bilder | ⚠️ Buch-Inhalt |
| `output/` | Fertige PDFs | ⚠️ Buch-Inhalt |

### Was wird NICHT geteilt?

- ❌ Keine Netzwerk-Calls außer Edubase
- ❌ Keine Telemetrie
- ❌ Keine Cloud-Uploads
- ❌ Keine Analytics

### Empfehlungen

1. ✅ Nutze nur für eigene gekaufte Bücher
2. ✅ Halte PDFs privat
3. ✅ Lösche Screenshots nach PDF-Erstellung
4. ✅ Backup von `output/` regelmäßig

---

## 🔧 Wartung & Updates

### Screenshots löschen (Speicherplatz freigeben)
```bash
rm -rf input_pages/*.png
```

### Alles zurücksetzen
```bash
rm -rf input_pages/*.png output/*.pdf ~/.pw_edubase/
```

### Python-Pakete updaten
```bash
source .venv/bin/activate
pip install --upgrade -r requirements.txt
```

### Playwright Browser updaten
```bash
source .venv/bin/activate
playwright install chromium
```

---

## 📞 Support-Matrix

| Problem | Lösung in Datei | Kapitel |
|---------|-----------------|---------|
| Schnellstart | `QUICKSTART.md` | - |
| Setup-Probleme | `README.md` | Troubleshooting |
| Viewer-Einstellung | `TUTORIAL.md` | - |
| Screenshot-Qualität | `TUTORIAL.md` | Perfekte Settings |
| OCR-Probleme | `README.md` | Troubleshooting |
| Performance | `README.md` | Performance & Benchmarks |
| Andere Bücher | `README.md` | Erweiterte Nutzung |

---

## 🎓 Best Practices

### ✅ DO's

- Nutze `./capture.sh` und `./build_pdf.sh` (nicht Python direkt)
- Lies `QUICKSTART.md` vor dem ersten Start
- Stelle Viewer richtig ein (siehe `TUTORIAL.md`)
- Warte bis Capture fertig ist (nicht unterbrechen)
- Validiere PDF-Qualität mit 2-3 Test-Seiten zuerst
- Lösche Screenshots nach erfolgreichem PDF-Build

### ❌ DON'Ts

- Nicht in Browser klicken während Capture
- Nicht Browser-Fenster minimieren während Capture
- Nicht mehrere Captures parallel
- Nicht PDFs weitergeben (Copyright!)
- Nicht setup-Schritte überspringen

---

## 📝 Checkliste für ersten Start

```
[ ] README.md oder QUICKSTART.md gelesen
[ ] System-Pakete installiert (tesseract, ocrmypdf, etc.)
[ ] Python venv erstellt
[ ] pip install -r requirements.txt ausgeführt
[ ] playwright install chromium ausgeführt
[ ] TUTORIAL.md gelesen (Viewer-Setup)
[ ] ./capture.sh gestartet
[ ] In Edubase eingeloggt
[ ] Viewer richtig eingestellt
[ ] Screenshots erfolgreich erstellt
[ ] ./build_pdf.sh gestartet
[ ] PDF erfolgreich erstellt
[ ] PDF-Qualität geprüft (Suche funktioniert?)
```

**Alle ✓? Gratulation! Du bist Profi! 🎉**

---

**Viel Erfolg mit deinem Projekt!** 🚀📚
