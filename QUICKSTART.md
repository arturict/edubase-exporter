# 🚀 QUICK START - Edubase to PDF

**Erstelle ein durchsuchbares PDF in nur 3 Schritten!**

---

## ⚡ 3 Befehle = Fertig

### 1️⃣ Projekt herunterladen & Setup

```bash
cd /home/artur/repos/edubase-exporter

# Einfach mit Makefile:
make install

# Oder manuell:
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
playwright install chromium
```

**Das war's!** Setup ist fertig.

---

### 2. Screenshots erstellen

```bash
./capture.sh
```

1. Browser öffnet sich
2. Einloggen in Edubase
3. Viewer einstellen (Fit to page, Zoom 100-120%)
4. Enter drücken
5. Warten (~10 Minuten)

**Ergebnis:** 396 Screenshots in `input_pages/`

---

### 3. PDF bauen

```bash
./build_pdf.sh
```

1. Enter drücken
2. Warten (~12 Minuten)
3. Fertig!

**Ergebnis:** `output/edubase_60505.pdf` 🎉

---

## 📖 PDF öffnen

```bash
xdg-open output/edubase_60505.pdf
```

Jetzt kannst du:
- ✅ Im PDF suchen (Ctrl+F)
- ✅ Text markieren & kopieren
- ✅ Offline lesen

---

## ❓ Probleme?

### Browser startet nicht
```bash
sudo apt install -y libglib2.0-0 libnss3 libatk1.0-0
```

### OCR fehlt
```bash
sudo apt install -y tesseract-ocr tesseract-ocr-deu ocrmypdf
```

### Mehr Hilfe
Siehe: `README.md` für ausführliche Anleitung

---

**Das war's! So einfach geht's 🎓**
