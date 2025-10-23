# Tests

Unit tests for the edubase-exporter project.

## Running Tests

### Install test dependencies:
```bash
pip install pytest pytest-cov
```

### Run all tests:
```bash
pytest tests/
```

### Run with coverage:
```bash
pytest tests/ --cov=. --cov-report=html
```

### Run specific test file:
```bash
pytest tests/test_edubase_to_pdf.py -v
```

### Run integration tests (optional):
```bash
pytest tests/ -m integration
```

## Test Structure

- `test_edubase_to_pdf.py` - Main unit tests
- `conftest.py` - Pytest configuration

## Coverage

Expected coverage: >80% for utility functions
