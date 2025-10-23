#!/bin/bash
# Edubase to PDF - Screenshot Capture
# Part 1 of 2: Captures screenshots from Edubase viewer

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
BOOK_ID="60505"
PAGES=396
OUT_DIR="./input_pages"
BOOK_URL="https://app.edubase.ch/#doc/${BOOK_ID}/1"

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo -e "${RED}${BOLD}❌ Fehler: Virtual Environment nicht gefunden!${NC}"
    echo ""
    echo "Bitte führe zuerst das Setup aus:"
    echo "  python3 -m venv .venv"
    echo "  source .venv/bin/activate"
    echo "  pip install -r requirements.txt"
    echo "  playwright install chromium"
    exit 1
fi

# Activate virtual environment
source .venv/bin/activate

# Print header
clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${BOLD}📸 EDUBASE TO PDF - SCREENSHOT CAPTURE${NC}                         ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Buch:${NC}   https://app.edubase.ch/#doc/${BOOK_ID} (ID: ${BOOK_ID})"
echo -e "${BOLD}Seiten:${NC} ${PAGES} Seiten"
echo -e "${BOLD}Dauer:${NC}  ~10-12 Minuten (1.5s pro Seite)"
echo ""
echo -e "${BLUE}────────────────────────────────────────────────────────────────────${NC}"
echo ""

# Check if resuming
EXISTING_IMAGES=$(ls -1 "$OUT_DIR"/*.png 2>/dev/null | wc -l)
if [ "$EXISTING_IMAGES" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Es existieren bereits $EXISTING_IMAGES Screenshots in $OUT_DIR${NC}"
    echo ""
    echo "Möchtest du:"
    echo "  [1] Von vorne anfangen (löscht alte Screenshots)"
    echo "  [2] Fortfahren (überspringt existierende Seiten)"
    echo "  [3] Abbrechen"
    echo ""
    read -p "Wähle (1/2/3): " CHOICE
    
    case $CHOICE in
        1)
            echo -e "${YELLOW}🗑️  Lösche alte Screenshots...${NC}"
            rm -f "$OUT_DIR"/*.png
            echo -e "${GREEN}✓ Bereit für neuen Capture${NC}"
            echo ""
            ;;
        2)
            echo -e "${BLUE}ℹ️  Fortfahren ab nächster fehlender Seite${NC}"
            echo ""
            ;;
        3)
            echo -e "${RED}Abgebrochen.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Ungültige Eingabe. Abgebrochen.${NC}"
            exit 1
            ;;
    esac
fi

# Instructions
echo -e "${BOLD}📋 SO FUNKTIONIERT'S:${NC}"
echo ""
echo -e "  ${GREEN}1.${NC} Browser öffnet sich automatisch mit Edubase"
echo -e "  ${GREEN}2.${NC} ${BOLD}Logge dich ein${NC} (falls nötig - wird gespeichert)"
echo -e "  ${GREEN}3.${NC} ${BOLD}Wichtig:${NC} Stelle im Viewer ein:"
echo -e "      • Ansicht: ${YELLOW}Fit to width${NC} oder ${YELLOW}Fit to page${NC}"
echo -e "      • Zoom: ${YELLOW}100-120%${NC} (gut lesbar)"
echo -e "      • Keine Seitenleiste/Menüs im Weg"
echo -e "  ${GREEN}4.${NC} Drücke ${BOLD}Enter${NC} im Terminal → Capture startet"
echo ""
echo -e "${BLUE}────────────────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD}Tipps:${NC}"
echo -e "  • Touchscreen/Maus nicht berühren während Capture"
echo -e "  • Browser-Fenster sichtbar lassen (nicht minimieren)"
echo -e "  • Bei Problemen: ${YELLOW}Ctrl+C${NC} zum Abbrechen, neu starten"
echo ""
echo -e "${BLUE}────────────────────────────────────────────────────────────────────${NC}"
echo ""
read -p "$(echo -e ${BOLD}${GREEN}Bereit? Drücke Enter zum Starten...${NC}) "

echo ""
echo -e "${BLUE}🚀 Starte Browser...${NC}"
echo ""
echo -e "${BOLD}Hinweis:${NC}"
echo -e "  • Der Script nutzt ${GREEN}direkte URL-Navigation${NC} zu jeder Seite"
echo -e "  • Format: https://app.edubase.ch/#doc/${BOOK_ID}/${YELLOW}SEITENNUMMER${NC}"
echo -e "  • Schneller und zuverlässiger als manuelles Blättern"
echo ""
echo -e "${BLUE}────────────────────────────────────────────────────────────────────${NC}"
echo ""

# Check which CLI to use (prefer new CLI with better UX)
if [ -f "edubase_cli.py" ]; then
    # Use new CLI with Rich output
    python3 edubase_cli.py capture \
        --book-url "$BOOK_URL" \
        --pages $PAGES \
        --out-dir "$OUT_DIR" \
        --user-data-dir ~/.edubase_browser \
        --delay-ms 1500 \
        --crop
else
    # Fallback to old CLI
    python3 edubase_to_pdf.py capture \
        --book-url "$BOOK_URL" \
        --pages $PAGES \
        --out-dir "$OUT_DIR" \
        --user-data-dir ~/.pw_edubase \
        --advance-with-keys \
        --delay-ms 1500 \
        --fullpage \
        --crop --crop-threshold 248 --crop-margin 10
fi

# Success message
CAPTURED_IMAGES=$(ls -1 "$OUT_DIR"/*.png 2>/dev/null | wc -l)
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${BOLD}✓ CAPTURE ERFOLGREICH ABGESCHLOSSEN!${NC}                          ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Ergebnis:${NC}"
echo -e "  📁 Ort:      $OUT_DIR/"
echo -e "  📄 Dateien:  $CAPTURED_IMAGES Screenshots"
echo -e "  💾 Größe:    $(du -sh "$OUT_DIR" | cut -f1)"
echo ""
echo -e "${BLUE}────────────────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD}${GREEN}➜ NÄCHSTER SCHRITT:${NC} PDF mit OCR erstellen"
echo ""
echo -e "  Führe aus: ${YELLOW}./build_pdf.sh${NC}"
echo ""
echo -e "  Das wird:"
echo -e "    • Screenshots zu PDF zusammenfügen"
echo -e "    • Deutsche OCR-Texterkennung durchführen"
echo -e "    • Durchsuchbares PDF erstellen"
echo -e "    • Dauer: ~3-5 Minuten (je nach CPU)"
echo ""
