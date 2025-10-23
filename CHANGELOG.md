# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2024-10-23

### 🎉 Major Release: Cross-Platform Support with Excellent UX

### Added
- ✨ **New `edubase_cli.py`** - Modern CLI with Rich library integration
  - Beautiful colored terminal output
  - Interactive progress bars with time estimates
  - Smart prompts and confirmations
  - Cross-platform path handling
  - System detection (Windows/WSL/Linux/macOS)
  
- 🪟 **Full Windows Support**
  - Native Windows batch scripts (`capture.bat`, `build.bat`)
  - PowerShell scripts with colors (`capture.ps1`, `build.ps1`)
  - Comprehensive Windows setup guide (`docs/WINDOWS_SETUP.md`)
  - WSL2 integration support
  - Platform-specific help messages

- 🎨 **Rich Terminal UI**
  - Colorful panels and tables
  - Spinners for long operations
  - Real-time progress tracking
  - Formatted file sizes and time estimates
  - Interactive file overwrite prompts

- 🔧 **Setup Automation**
  - `setup.sh` for Linux/macOS/WSL2
  - `setup.ps1` for Windows
  - Automatic dependency detection
  - One-command installation

- 📚 **Enhanced Documentation**
  - `QUICKREF.md` - Quick reference card
  - `docs/WINDOWS_SETUP.md` - Complete Windows guide
  - Updated README with multi-platform instructions
  - Better troubleshooting sections

- ✅ **System Check Command**
  - `python edubase_cli.py check`
  - Verifies all dependencies
  - Shows platform-specific installation hints
  - Lists missing tools with install commands

### Changed
- 📦 **Updated Dependencies**
  - Added `click>=8.1.0` for CLI framework
  - Added `rich>=13.0.0` for terminal UI
  - Added `colorama>=0.4.6` for Windows color support
  - Replaced `tqdm` with Rich progress bars

- 🔄 **Improved Shell Scripts**
  - `capture.sh` and `build_pdf.sh` now auto-detect new CLI
  - Fallback to old CLI if new one not available
  - Better error messages
  - Platform detection

- 🎯 **Better User Experience**
  - Clear step-by-step instructions
  - Resume functionality with prompts
  - File size formatting (KB, MB, GB)
  - Time estimates for operations
  - Smart defaults for all options

### Fixed
- 🐛 **Path Handling**
  - Windows paths with backslashes
  - WSL cross-filesystem paths (`/mnt/c/...`)
  - Tilde expansion (`~/...`)
  - Relative vs absolute paths

- 🔧 **Windows Compatibility**
  - Browser launch on Windows
  - PowerShell execution policies
  - Line ending issues (CRLF vs LF)
  - Environment variable handling

### Technical Details

#### New Architecture
```
┌─────────────────────────────────────────┐
│         User Interface Layer             │
│  (edubase_cli.py with Rich/Click)       │
├─────────────────────────────────────────┤
│       Cross-Platform Scripts             │
│  setup.sh/ps1, capture.sh/ps1/bat       │
├─────────────────────────────────────────┤
│         Core Logic Layer                 │
│  (edubase_to_pdf.py - unchanged)        │
├─────────────────────────────────────────┤
│         External Tools                   │
│  playwright, ocrmypdf, tesseract        │
└─────────────────────────────────────────┘
```

#### Compatibility Matrix
| Feature | Linux | macOS | WSL2 | Windows Native |
|---------|-------|-------|------|----------------|
| Screenshots | ✅ | ✅ | ✅ | ✅ |
| OCR | ✅ | ✅ | ✅ | ⚠️ (via WSL/Docker) |
| Setup Script | ✅ | ✅ | ✅ | ✅ |
| Rich UI | ✅ | ✅ | ✅ | ✅ |
| Auto-Resume | ✅ | ✅ | ✅ | ✅ |

### Migration Guide

#### For Existing Users

No breaking changes! Old workflow still works:
```bash
./capture.sh
./build_pdf.sh
```

New workflow (optional, better UX):
```bash
python edubase_cli.py capture --book-url "URL" --pages NUM
python edubase_cli.py build --input ./input_pages --output ./output/book.pdf
```

#### For Windows Users

New Windows support:
```powershell
# Setup
.\setup.ps1

# Capture
.\capture.ps1

# Build (use WSL for OCR)
wsl
./build_pdf.sh
```

See `docs/WINDOWS_SETUP.md` for complete guide.

### Statistics

- **Files Added**: 10
  - `edubase_cli.py` (660 lines)
  - `capture.bat`, `capture.ps1`
  - `build.bat`, `build.ps1`
  - `setup.sh`, `setup.ps1`
  - `docs/WINDOWS_SETUP.md`
  - `QUICKREF.md`
  - `CHANGELOG.md`

- **Files Modified**: 5
  - `requirements.txt` (added click, rich, colorama)
  - `README.md` (multi-platform instructions)
  - `capture.sh` (auto-detect new CLI)
  - `build_pdf.sh` (auto-detect new CLI)

- **Total Lines Added**: ~3,500
- **Documentation Pages**: +2

---

## [1.0.0] - 2024-10-23

### Initial Release

- ✨ Screenshot capture from Edubase viewer
- 🔤 German OCR text recognition
- 📄 PDF creation with metadata
- ✂️ Auto-crop functionality
- 🔄 Resume interrupted captures
- 📚 Comprehensive documentation
- 🧪 Unit tests
- 🎯 Direct URL navigation

### Features
- Playwright-based browser automation
- OCRmyPDF integration
- PIL/Pillow image processing
- img2pdf PDF generation
- pikepdf metadata handling
- Progress tracking with tqdm

### Platforms
- Linux (Ubuntu 24.04)
- WSL2 (Windows Subsystem for Linux)

---

## Version Numbering

We use [Semantic Versioning](https://semver.org/):
- MAJOR version for incompatible API changes
- MINOR version for added functionality (backwards-compatible)
- PATCH version for backwards-compatible bug fixes

---

## Future Plans

### Planned for 2.1.0
- [ ] GUI version (Tkinter/Qt)
- [ ] Batch processing multiple books
- [ ] Cloud storage integration
- [ ] Advanced OCR options (layout analysis)

### Under Consideration
- [ ] Docker image for easy deployment
- [ ] Web interface
- [ ] Book preview before download
- [ ] Automatic book ID detection

---

**Legend:**
- ✨ New feature
- 🎨 UI/UX improvement
- 🐛 Bug fix
- 🔧 Technical change
- 📚 Documentation
- ⚠️ Important note
