# 🪟 Windows Setup Guide

Complete guide for running Edubase Exporter on Windows with excellent user experience.

---

## 🎯 Quick Start (Choose Your Method)

### Option 1: WSL2 (Recommended) ⭐
Best compatibility, full features, native Linux tools.

### Option 2: Native Windows
Screenshots work, but OCR requires additional setup or Docker.

---

## 📋 Prerequisites

### All Methods Need:
1. **Python 3.8+**
   - Download: https://www.python.org/downloads/
   - ✅ **Important:** Check "Add Python to PATH" during installation

2. **Git** (optional, for cloning)
   - Download: https://git-scm.com/download/win

---

## 🚀 Method 1: WSL2 Setup (Recommended)

WSL2 gives you a real Linux environment on Windows. Best for this project!

### Step 1: Install WSL2

Open **PowerShell as Administrator** and run:

```powershell
wsl --install
```

This installs Ubuntu by default. Restart your computer when prompted.

### Step 2: Open Ubuntu

1. Search for "Ubuntu" in Start Menu
2. First time: Create username/password
3. You're now in Linux! 🐧

### Step 3: Install System Dependencies

```bash
sudo apt update
sudo apt install -y \
    python3.12-venv \
    python3-pip \
    tesseract-ocr \
    tesseract-ocr-deu \
    ocrmypdf \
    ghostscript \
    poppler-utils
```

### Step 4: Clone or Access Project

**Option A:** Clone in WSL
```bash
cd ~
git clone <your-repo-url>
cd edubase-exporter
```

**Option B:** Access Windows files from WSL
```bash
cd /mnt/c/Users/YourUsername/Downloads/edubase-exporter
```

Your C: drive is at `/mnt/c/` in WSL!

### Step 5: Setup Python Environment

```bash
# Create virtual environment
python3 -m venv .venv

# Activate it
source .venv/bin/activate

# Install Python packages
pip install -r requirements.txt

# Install browser
playwright install chromium
playwright install-deps
```

### Step 6: Run the Tool

```bash
# Capture screenshots
./capture.sh

# Build PDF with OCR
./build.sh
```

✅ **Done!** You're using the full Linux version with all features.

---

## 🪟 Method 2: Native Windows Setup

Capture works great, OCR needs extra steps.

### Step 1: Install Python

1. Download from https://www.python.org/downloads/
2. Run installer
3. ✅ **Check "Add Python to PATH"**
4. Click "Install Now"

### Step 2: Open PowerShell or Command Prompt

Right-click Start → "Windows PowerShell" or "Terminal"

### Step 3: Navigate to Project

```powershell
cd C:\Users\YourName\Downloads\edubase-exporter
```

### Step 4: Create Virtual Environment

```powershell
# Create venv
python -m venv .venv

# Activate it (PowerShell)
.\.venv\Scripts\Activate.ps1

# Or activate it (Command Prompt)
.venv\Scripts\activate.bat
```

### Step 5: Install Python Packages

```powershell
pip install -r requirements.txt
playwright install chromium
```

### Step 6: Run Screenshot Capture

**PowerShell:**
```powershell
.\capture.ps1
```

**Command Prompt:**
```cmd
capture.bat
```

**Or use Python CLI directly:**
```powershell
python edubase_cli.py capture --book-url "https://app.edubase.ch/#doc/60505/1" --pages 396
```

✅ Screenshots work perfectly on Windows!

### Step 7: OCR (PDF Building) on Windows

OCR is tricky on native Windows. **Choose one:**

#### Option A: Use WSL2 for OCR Only
1. Install WSL2 (see Method 1, Step 1)
2. Install dependencies in WSL (see Method 1, Step 3)
3. Run in WSL:
   ```bash
   cd /mnt/c/Users/YourName/Downloads/edubase-exporter
   python3 edubase_cli.py build --input ./input_pages --output ./output/book.pdf
   ```

#### Option B: Docker (Advanced)
Use Docker Desktop with OCRmyPDF image:
```powershell
docker run --rm -v "${PWD}:/data" jbarlow83/ocrmypdf --help
```

#### Option C: Manual Tesseract + OCRmyPDF
1. Install Tesseract: https://github.com/UB-Mannheim/tesseract/wiki
2. Install Ghostscript: https://www.ghostscript.com/download/gsdnld.html
3. Install OCRmyPDF: `pip install ocrmypdf`
4. May need additional configuration

---

## 🎨 Using the New CLI (All Platforms)

### Capture Command

```powershell
python edubase_cli.py capture --help
```

**Example:**
```powershell
python edubase_cli.py capture `
    --book-url "https://app.edubase.ch/#doc/60505/1" `
    --pages 396 `
    --out-dir "./input_pages" `
    --delay-ms 1500 `
    --crop
```

### Build Command

```powershell
python edubase_cli.py build --help
```

**Example:**
```powershell
python edubase_cli.py build `
    --input "./input_pages" `
    --output "./output/book.pdf" `
    --title "My Book" `
    --author "Author Name" `
    --lang deu `
    --jobs 6
```

### Check System

```powershell
python edubase_cli.py check
```

This shows what's installed and what's missing!

---

## 🎯 Recommended Workflows

### Workflow 1: Pure WSL2 ⭐ (Best)
✅ Full features  
✅ Best compatibility  
✅ Easy to use  

```bash
# Everything in WSL
./capture.sh
./build.sh
```

### Workflow 2: Hybrid (Good)
✅ GUI apps in Windows  
✅ OCR in WSL  

```powershell
# Capture in Windows (GUI browser)
.\capture.ps1

# Build in WSL (OCR tools)
wsl
cd /mnt/c/Users/YourName/path/to/project
./build.sh
```

### Workflow 3: Docker for OCR (Advanced)
✅ No WSL needed  
❌ Requires Docker setup  

Use Docker for just the OCR step.

---

## 🎨 User Experience Features

### Rich Terminal Output
- 🎨 **Colored output** (via Rich library)
- 📊 **Progress bars** with time estimates
- ✨ **Beautiful tables** and panels
- 🔍 **Interactive prompts**

### Cross-Platform Paths
- ✅ Works with Windows paths (`C:\Users\...`)
- ✅ Works with WSL paths (`/mnt/c/...`)
- ✅ Automatic path conversion

### Smart Detection
- 🔍 Detects Windows vs WSL vs Linux
- 🛠️ Shows platform-specific help
- 📋 Checks dependencies automatically

### User-Friendly
- ❓ Interactive confirmations
- 🔄 Resume after interruption
- 📝 Clear error messages with solutions
- 💡 Helpful tips and suggestions

---

## 🐛 Troubleshooting Windows Issues

### "Python not found"
✅ **Solution:** Add Python to PATH
1. Search "Edit environment variables" in Start Menu
2. Click "Environment Variables"
3. Under "User variables", find "Path"
4. Add: `C:\Users\YourName\AppData\Local\Programs\Python\Python3XX`

### "playwright command not found"
✅ **Solution:** Activate virtual environment first
```powershell
.\.venv\Scripts\Activate.ps1
```

### "Cannot run scripts" (PowerShell)
✅ **Solution:** Change execution policy
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Browser doesn't start"
✅ **Solution:** Install browser dependencies
```powershell
playwright install chromium
playwright install-deps
```

### "OCR fails on Windows"
✅ **Solution:** Use WSL2 for OCR
```powershell
wsl
cd /mnt/c/path/to/project
./build.sh
```

### WSL: "Permission denied"
✅ **Solution:** Make scripts executable
```bash
chmod +x capture.sh build.sh edubase_to_pdf.py
```

### WSL: "Cannot find file"
✅ **Solution:** Check line endings
Windows uses CRLF, Linux uses LF. Convert:
```bash
sudo apt install dos2unix
dos2unix capture.sh build.sh
```

### "Import error: click" or "Import error: rich"
✅ **Solution:** Install/update requirements
```powershell
pip install -r requirements.txt --upgrade
```

---

## 📊 Performance on Windows

### Native Windows (Screenshots Only)
| Phase | Speed | Notes |
|-------|-------|-------|
| Capture | ⚡ Fast | Native browser, good performance |
| OCR | ⚠️ Varies | Depends on OCR method |

### WSL2 (Full Pipeline)
| Phase | Speed | Notes |
|-------|-------|-------|
| Capture | ⚡ Fast | Good performance |
| OCR | ⚡ Fast | Native Linux tools |

**Tip:** WSL2 gives you the best of both worlds!

---

## 🎓 Tips for Best Experience on Windows

### 1. Use Windows Terminal
Modern terminal with tabs, better colors:
- Install from Microsoft Store: "Windows Terminal"
- Much better than old cmd.exe

### 2. Use VS Code with WSL
Perfect IDE integration:
- Install VS Code
- Install "Remote - WSL" extension
- Open project in WSL: `code .`

### 3. File Access
Access Windows files from WSL:
```bash
# Windows C: drive
cd /mnt/c/Users/YourName/Documents

# Windows D: drive
cd /mnt/d/
```

Access WSL files from Windows:
```
\\wsl$\Ubuntu\home\yourusername\
```

### 4. Path Tips
Always use forward slashes `/` in CLI, even on Windows:
```powershell
# Good
python edubase_cli.py build --input ./input_pages

# Also works
python edubase_cli.py build --input .\input_pages
```

### 5. Colors in Windows
For best colors:
- Use Windows Terminal (not cmd.exe)
- PowerShell 7+ recommended
- Install from: https://github.com/PowerShell/PowerShell

---

## 🔍 System Check

Check what's working:

```powershell
python edubase_cli.py check
```

This shows:
- ✅ Python version
- ✅ Operating system
- ✅ Installed packages
- ✅ System tools (OCR, Tesseract)
- ✅ Platform-specific hints

---

## 🆘 Getting Help

### See all commands:
```powershell
python edubase_cli.py --help
```

### Get help for specific command:
```powershell
python edubase_cli.py capture --help
python edubase_cli.py build --help
```

### Check system status:
```powershell
python edubase_cli.py check
```

---

## 🎉 Summary

### ✅ What Works Great on Windows:
- Screenshot capture
- Image processing
- Browser automation
- PDF creation (without OCR)

### ⚠️ What Needs WSL2:
- OCR text recognition
- Full pipeline automation

### ⭐ Recommended:
Use WSL2 for complete, hassle-free experience!

---

**Questions?** Check the main README.md or run `python edubase_cli.py check`
