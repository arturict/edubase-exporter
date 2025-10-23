# 🚀 Quick Reference Card

## Installation

### Linux / macOS / WSL2
```bash
./setup.sh
```

### Windows
```powershell
.\setup.ps1
```

---

## Usage

### Capture Screenshots

**Linux/macOS/WSL2:**
```bash
./capture.sh
# or
python edubase_cli.py capture --book-url "URL" --pages NUM
```

**Windows:**
```powershell
.\capture.ps1
# or
python edubase_cli.py capture --book-url "URL" --pages NUM
```

### Build PDF

**Linux/macOS/WSL2:**
```bash
./build_pdf.sh
# or
python edubase_cli.py build --input ./input_pages --output ./output/book.pdf
```

**Windows:**
```powershell
.\build.ps1
# or (WSL recommended for OCR)
python edubase_cli.py build --input ./input_pages --output ./output/book.pdf
```

---

## CLI Commands

### Check System
```bash
python edubase_cli.py check
```

### Get Help
```bash
python edubase_cli.py --help
python edubase_cli.py capture --help
python edubase_cli.py build --help
```

### Capture with Options
```bash
python edubase_cli.py capture \
    --book-url "https://app.edubase.ch/#doc/60505/1" \
    --pages 396 \
    --out-dir ./input_pages \
    --delay-ms 1500 \
    --crop
```

### Build with Options
```bash
python edubase_cli.py build \
    --input ./input_pages \
    --output ./output/book.pdf \
    --title "My Book" \
    --author "Author Name" \
    --lang deu \
    --jobs 6 \
    --dpi 300
```

---

## Configuration

### Edit capture.sh / capture.ps1
```bash
BOOK_ID="60505"           # Your book ID
PAGES=396                 # Total pages
```

### Edit build_pdf.sh / build.ps1
```bash
OUTPUT_FILE="./output/book.pdf"
BOOK_TITLE="My Book Title"
BOOK_AUTHOR="Author Name"
```

---

## Common Tasks

### Resume Interrupted Capture
```bash
# Automatically resumes from last page
./capture.sh
# Or specify start page:
python edubase_cli.py capture --book-url "URL" --pages NUM --start-index 50
```

### Change OCR Language
```bash
# German + English
python edubase_cli.py build --lang deu+eng ...

# English only
python edubase_cli.py build --lang eng ...
```

### Reduce PDF Size
```bash
python edubase_cli.py build \
    --jpeg-quality 85 \
    --optimize 3 \
    ...
```

### Higher Quality
```bash
python edubase_cli.py build \
    --jpeg-quality 95 \
    --dpi 600 \
    ...
```

---

## Troubleshooting

### Check What's Working
```bash
python edubase_cli.py check
```

### Windows: OCR Not Working
Use WSL2:
```powershell
wsl --install
wsl
cd /mnt/c/path/to/project
./setup.sh
./build_pdf.sh
```

### Browser Won't Start
```bash
playwright install chromium
playwright install-deps
```

### "Module not found"
```bash
source .venv/bin/activate    # Linux/Mac
.\.venv\Scripts\Activate.ps1  # Windows
pip install -r requirements.txt
```

---

## File Locations

```
edubase-exporter/
├── input_pages/     ← Screenshots go here
├── output/          ← PDFs saved here
├── .venv/           ← Python virtual environment
├── capture.sh       ← Capture script (Linux/Mac)
├── capture.ps1      ← Capture script (Windows)
├── build_pdf.sh     ← Build script (Linux/Mac)
├── build.ps1        ← Build script (Windows)
├── edubase_cli.py   ← New CLI with Rich output
└── edubase_to_pdf.py ← Original CLI (fallback)
```

---

## Features

✨ **Cross-Platform** - Windows, macOS, Linux, WSL2  
🎨 **Beautiful UI** - Rich terminal output with colors  
📊 **Progress Bars** - Real-time progress tracking  
🔄 **Resume Support** - Continue after interruption  
🔍 **OCR** - Full German text recognition  
✂️ **Auto-Crop** - Removes white margins  
⚡ **Fast** - Direct URL navigation  
🛡️ **Safe** - No data loss, skip existing files  

---

## Links

📖 Full Documentation: `README.md`  
🪟 Windows Guide: `docs/WINDOWS_SETUP.md`  
📚 Tutorial: `docs/TUTORIAL.md`  
🏗️ Architecture: `docs/PROJECT_OVERVIEW.md`  

---

## Support

Run system check:
```bash
python edubase_cli.py check
```

Get help:
```bash
python edubase_cli.py --help
```

See specific command help:
```bash
python edubase_cli.py capture --help
python edubase_cli.py build --help
```
