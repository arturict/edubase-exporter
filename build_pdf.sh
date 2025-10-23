#!/bin/bash
# Edubase to PDF - PDF Builder with OCR
# Part 2 of 2: Converts screenshots to searchable PDF

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for better UX
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
INPUT_DIR="./input_pages"
OUTPUT_FILE="./output/edubase_60505.pdf"
BOOK_TITLE="Edubase Book 60505"
BOOK_AUTHOR="Edubase"
BOOK_ID="60505"

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo -e "${RED}${BOLD}❌ Fehler: Virtual Environment nicht gefunden!${NC}"
    echo ""
    echo "Bitte führe zuerst das Setup aus."
    exit 1
fi

# Activate virtual environment
source .venv/bin/activate

# Print header
clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${BOLD}📚 EDUBASE TO PDF - PDF BUILDER (OCR)${NC}                         ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if screenshots exist
if [ ! "$(ls -A "$INPUT_DIR"/*.png 2>/dev/null)" ]; then
    echo -e "${RED}${BOLD}❌ FEHLER: Keine Screenshots gefunden!${NC}"
    echo ""
    echo -e "${YELLOW}Keine .png Dateien in $INPUT_DIR/${NC}"
    echo ""
    echo -e "Bitte führe zuerst aus: ${BOLD}./capture.sh${NC}"
    echo ""
    exit 1
fi

IMAGE_COUNT=$(ls -1 "$INPUT_DIR"/*.png 2>/dev/null | wc -l)
IMAGE_SIZE=$(du -sh "$INPUT_DIR" | cut -f1)

echo -e "${BOLD}Eingabe:${NC}"
echo -e "  📁 Verzeichnis:  $INPUT_DIR/"
echo -e "  📄 Screenshots:  $IMAGE_COUNT Dateien"
echo -e "  💾 Größe:        $IMAGE_SIZE"
echo ""
echo -e "${BOLD}Ausgabe:${NC}"
echo -e "  📄 PDF:          $OUTPUT_FILE"
echo -e "  🔤 OCR-Sprache:  Deutsch"
echo -e "  ⚙️  DPI:          300"
echo ""
echo -e "${BLUE}────────────────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD}📋 VERARBEITUNGSSCHRITTE:${NC}"
echo ""
echo -e "  ${GREEN}1.${NC} Bilder vorverarbeiten (Crop, JPEG-Konvertierung)"
echo -e "  ${GREEN}2.${NC} PDF aus Bildern erstellen"
echo -e "  ${GREEN}3.${NC} OCR-Texterkennung durchführen (Deutsch)"
echo -e "  ${GREEN}4.${NC} PDF optimieren & Metadaten setzen"
echo ""
echo -e "${YELLOW}⏱️  Geschätzte Dauer: 10-15 Minuten (je nach CPU-Leistung)${NC}"
echo ""
echo -e "${BLUE}────────────────────────────────────────────────────────────────────${NC}"
echo ""

# Check if output file already exists
if [ -f "$OUTPUT_FILE" ]; then
    echo -e "${YELLOW}⚠️  Eine PDF-Datei existiert bereits:${NC}"
    echo -e "    $OUTPUT_FILE"
    echo ""
    read -p "Überschreiben? (j/n): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[jJ]$ ]]; then
        echo -e "${RED}Abgebrochen.${NC}"
        exit 0
    fi
    echo ""
fi

read -p "$(echo -e ${BOLD}${GREEN}Bereit? Drücke Enter zum Starten...${NC}) "

echo ""
echo -e "${BLUE}🔧 Starte PDF-Erstellung...${NC}"
echo ""

# Run build with progress
python edubase_to_pdf.py build \
    --input "$INPUT_DIR" \
    --output "$OUTPUT_FILE" \
    --lang deu \
    --jobs 6 \
    --optimize 2 \
    --deskew \
    --crop --crop-threshold 248 --crop-margin 10 \
    --dpi 300 \
    --title "$BOOK_TITLE" \
    --author "$BOOK_AUTHOR" \
    --subject "Persönliche Studienkopie (OCR)"

# Get file info
if [ -f "$OUTPUT_FILE" ]; then
    PDF_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    PDF_SIZE_BYTES=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE")
    PDF_SIZE_MB=$(echo "scale=1; $PDF_SIZE_BYTES/1024/1024" | bc)
    
    # Success message
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}✓ PDF ERFOLGREICH ERSTELLT!${NC}                                   ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}📊 ERGEBNIS:${NC}"
    echo -e "  📄 Datei:     $OUTPUT_FILE"
    echo -e "  💾 Größe:     $PDF_SIZE (${PDF_SIZE_MB} MB)"
    echo ""
    
    # Validation with pdfinfo if available
    if command -v pdfinfo &> /dev/null; then
        echo -e "${BOLD}✓ PDF-Informationen:${NC}"
        PAGES=$(pdfinfo "$OUTPUT_FILE" 2>/dev/null | grep "Pages:" | awk '{print $2}')
        TITLE=$(pdfinfo "$OUTPUT_FILE" 2>/dev/null | grep "Title:" | cut -d: -f2- | xargs)
        echo -e "  📄 Seiten:    $PAGES"
        echo -e "  📖 Titel:     $TITLE"
        echo ""
    fi
    
    # Test OCR with pdftotext if available
    if command -v pdftotext &> /dev/null; then
        TEST_TEXT=$(pdftotext "$OUTPUT_FILE" - 2>/dev/null | head -c 200 | tr -d '\n' | sed 's/  */ /g')
        if [ -n "$TEST_TEXT" ]; then
            echo -e "${GREEN}✓ OCR-Text erfolgreich:${NC}"
            echo -e "  ${BOLD}Textauszug:${NC} ${TEST_TEXT:0:80}..."
            echo ""
        fi
    fi
    
    echo -e "${BLUE}────────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${BOLD}🎉 FERTIG! Du kannst jetzt:${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} PDF öffnen:"
    echo -e "     ${YELLOW}xdg-open $OUTPUT_FILE${NC}"
    echo ""
    echo -e "  ${GREEN}2.${NC} Im PDF suchen (Ctrl+F funktioniert!)"
    echo ""
    echo -e "  ${GREEN}3.${NC} Text markieren & kopieren"
    echo ""
    echo -e "  ${GREEN}4.${NC} Screenshots behalten für spätere Bearbeitung"
    echo -e "     oder löschen: ${YELLOW}rm -rf $INPUT_DIR/*.png${NC}"
    echo ""
    
    # Open PDF automatically if running in GUI environment
    if [ -n "$DISPLAY" ] && command -v xdg-open &> /dev/null; then
        echo -e "${BLUE}────────────────────────────────────────────────────────────────────${NC}"
        echo ""
        read -p "$(echo -e ${BOLD}PDF jetzt öffnen? (j/n):${NC}) " OPEN_PDF
        if [[ "$OPEN_PDF" =~ ^[jJ]$ ]]; then
            xdg-open "$OUTPUT_FILE" 2>/dev/null &
            echo -e "${GREEN}✓ PDF wird geöffnet...${NC}"
        fi
    fi
    
else
    echo ""
    echo -e "${RED}${BOLD}❌ FEHLER: PDF konnte nicht erstellt werden${NC}"
    echo ""
    echo "Bitte prüfe die Fehlermeldungen oben."
    exit 1
fi

echo ""
