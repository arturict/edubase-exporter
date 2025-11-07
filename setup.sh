#!/bin/bash
# Edubase Exporter - Automated Setup Script for Ubuntu
# Only works on Linux (Ubuntu, Debian, etc.)

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${BOLD}📦 Edubase Exporter - Ubuntu Setup${NC}                            ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo -e "${BOLD}Detected System:${NC} ${MACHINE}"
echo ""

if [ "$MACHINE" != "Linux" ]; then
    echo -e "${RED}❌ Error: This setup is only for Ubuntu/Linux${NC}"
    echo "Windows and macOS are no longer supported."
    exit 1
fi

# Check Python
echo -e "${BLUE}➜${NC} Checking Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo -e "  ${GREEN}✓${NC} Python ${PYTHON_VERSION} found"
else
    echo -e "  ${RED}✗${NC} Python 3 not found!"
    echo ""
    echo -e "${YELLOW}Please install Python 3.8 or higher:${NC}"
    echo "  sudo apt install python3 python3-venv python3-pip"
    exit 1
fi
echo ""

# Check/Install System Dependencies
echo -e "${BLUE}➜${NC} Checking system dependencies..."

MISSING=""
for cmd in tesseract ocrmypdf gs; do
    if ! command -v $cmd &> /dev/null; then
        MISSING="$MISSING $cmd"
    fi
done

if [ -n "$MISSING" ]; then
    echo -e "  ${YELLOW}⚠${NC} Missing:$MISSING"
    echo ""
    PROMPT="$(echo -e "${BOLD}${GREEN}Install system dependencies now? (y/n):${NC}")"
    read -p "$PROMPT " INSTALL
    if [ "$INSTALL" = "y" ] || [ "$INSTALL" = "Y" ]; then
        echo ""
        echo -e "${BLUE}Installing dependencies...${NC}"
        sudo apt update
        sudo apt install -y \
            tesseract-ocr \
            tesseract-ocr-deu \
            ocrmypdf \
            ghostscript \
            poppler-utils \
            qpdf
        echo -e "  ${GREEN}✓${NC} System dependencies installed"
    else
        echo -e "  ${YELLOW}⚠${NC} Skipping system dependencies"
        echo "  Note: OCR will not work without tesseract and ocrmypdf"
    fi
else
    echo -e "  ${GREEN}✓${NC} All system dependencies found"
fi
echo ""

# Create Virtual Environment
echo -e "${BLUE}➜${NC} Setting up Python virtual environment..."
if [ -d ".venv" ]; then
    echo -e "  ${YELLOW}⚠${NC} Virtual environment already exists"
    RECREATE_PROMPT="$(echo -e "${BOLD}Recreate it? (y/n):${NC}")"
    read -p "$RECREATE_PROMPT " RECREATE
    if [ "$RECREATE" = "y" ] || [ "$RECREATE" = "Y" ]; then
        rm -rf .venv
        python3 -m venv .venv
        echo -e "  ${GREEN}✓${NC} Virtual environment recreated"
    else
        echo -e "  ${BLUE}ℹ${NC} Using existing virtual environment"
    fi
else
    python3 -m venv .venv
    echo -e "  ${GREEN}✓${NC} Virtual environment created"
fi
echo ""

# Activate and install Python packages
echo -e "${BLUE}➜${NC} Installing Python packages..."
source .venv/bin/activate

pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt

echo -e "  ${GREEN}✓${NC} Python packages installed"
echo ""

# Install Playwright browser
echo -e "${BLUE}➜${NC} Installing Chromium browser for Playwright..."
playwright install chromium

echo ""
echo -e "${BLUE}➜${NC} Installing browser dependencies..."
playwright install-deps chromium

echo -e "  ${GREEN}✓${NC} Browser installed"
echo ""

# Create directories
echo -e "${BLUE}➜${NC} Creating directories..."
mkdir -p input_pages output
echo -e "  ${GREEN}✓${NC} Directories created"
echo ""

# Make scripts executable
echo -e "${BLUE}➜${NC} Making scripts executable..."
chmod +x edubase_to_pdf.py edubase_cli.py capture.sh build_pdf.sh 2>/dev/null || true
echo -e "  ${GREEN}✓${NC} Scripts ready"
echo ""

# Run system check
echo -e "${BLUE}➜${NC} Running system check..."
echo ""
python edubase_cli.py check
echo ""

# Success
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${BOLD}✓ Setup Complete!${NC}                                              ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo ""
echo -e "  ${GREEN}1.${NC} Capture screenshots:"
echo -e "     ${YELLOW}./capture.sh${NC}"
echo -e "     or: ${YELLOW}python edubase_cli.py capture --help${NC}"
echo ""
echo -e "  ${GREEN}2.${NC} Build PDF with OCR:"
echo -e "     ${YELLOW}./build_pdf.sh${NC}"
echo -e "     or: ${YELLOW}python edubase_cli.py build --help${NC}"
echo ""
echo -e "${BLUE}────────────────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD}Tips:${NC}"
echo -e "  • Edit ${YELLOW}capture.sh${NC} and ${YELLOW}build_pdf.sh${NC} to set your book ID"
echo -e "  • Use ${YELLOW}python edubase_cli.py --help${NC} for all commands"
echo ""
