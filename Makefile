.PHONY: help setup install check test coverage clean run-capture run-build format

help:
	@echo "📚 Edubase to PDF Exporter - Available Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup       - Run automated setup script (recommended)"
	@echo "  make install     - Install dependencies & setup project (manual)"
	@echo "  make check       - Check system requirements"
	@echo ""
	@echo "Running:"
	@echo "  make run-capture - Run screenshot capture"
	@echo "  make run-build   - Build PDF with OCR"
	@echo ""
	@echo "Testing:"
	@echo "  make test        - Run unit tests"
	@echo "  make coverage    - Run tests with coverage report"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean       - Remove temporary files"
	@echo "  make format      - Format Python code (requires black)"
	@echo ""
	@echo "CLI Usage:"
	@echo "  python edubase_cli.py --help"
	@echo "  python edubase_cli.py capture --help"
	@echo "  python edubase_cli.py build --help"

setup:
	@echo "🚀 Running automated setup..."
	@chmod +x setup.sh
	@./setup.sh

install:
	@echo "🔧 Installing dependencies..."
	python3 -m venv .venv
	.venv/bin/pip install --upgrade pip
	.venv/bin/pip install -r requirements.txt
	.venv/bin/playwright install chromium
	@echo "✅ Installation complete!"
	@echo ""
	@echo "💡 Tip: Use 'make check' to verify installation"

check:
	@echo "🔍 Checking system..."
	@. .venv/bin/activate && python edubase_cli.py check || python3 edubase_cli.py check 2>/dev/null || echo "⚠️  Please activate venv first: source .venv/bin/activate"

test:
	@echo "🧪 Running tests..."
	.venv/bin/pytest tests/ -v

coverage:
	@echo "📊 Running tests with coverage..."
	.venv/bin/pytest tests/ --cov=. --cov-report=html --cov-report=term
	@echo "📄 Coverage report: htmlcov/index.html"

clean:
	@echo "🧹 Cleaning up..."
	rm -rf __pycache__
	rm -rf .pytest_cache
	rm -rf htmlcov
	rm -rf .coverage
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	@echo "✅ Cleanup complete!"

run-capture:
	@./capture.sh

run-build:
	@./build_pdf.sh

format:
	@if command -v black >/dev/null 2>&1; then \
		echo "🎨 Formatting code..."; \
		black edubase_to_pdf.py tests/; \
		echo "✅ Formatting complete!"; \
	else \
		echo "⚠️  black not installed. Install with: pip install black"; \
	fi
