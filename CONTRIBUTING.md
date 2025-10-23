# Contributing to Edubase to PDF Exporter

Vielen Dank für dein Interesse am Projekt! 🎉

## 🚀 Quick Start für Entwickler

```bash
# Clone & Setup
git clone <repo-url>
cd edubase-exporter
make install

# Run tests
make test

# See all commands
make help
```

## 📋 Development Workflow

### 1. Setup Development Environment

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip install pytest pytest-cov black flake8
playwright install chromium
```

### 2. Make Changes

- Edit code in `edubase_to_pdf.py`
- Update tests in `tests/test_edubase_to_pdf.py`
- Update documentation as needed

### 3. Run Tests

```bash
# Run all tests
make test

# Run with coverage
make coverage

# Run specific test
pytest tests/test_edubase_to_pdf.py::TestUtilityFunctions -v
```

### 4. Code Quality

```bash
# Format code (optional)
black edubase_to_pdf.py tests/

# Lint code (optional)
flake8 edubase_to_pdf.py
```

## 🧪 Testing Guidelines

### Writing Tests

- Place tests in `tests/` directory
- Follow naming convention: `test_*.py`
- Use descriptive test names
- Group related tests in classes
- Use fixtures for setup/teardown

### Example Test:

```python
class TestMyFeature:
    """Test my new feature"""
    
    def test_feature_works(self):
        """Test that feature works correctly"""
        result = my_function()
        assert result == expected
```

### Running Specific Tests:

```bash
# Run all tests
pytest tests/

# Run specific file
pytest tests/test_edubase_to_pdf.py

# Run specific class
pytest tests/test_edubase_to_pdf.py::TestUtilityFunctions

# Run specific test
pytest tests/test_edubase_to_pdf.py::TestUtilityFunctions::test_natural_key_sorting
```

## 📝 Code Style

- Follow PEP 8 guidelines
- Use 4 spaces for indentation
- Maximum line length: 100 characters
- Use docstrings for functions
- Comment complex logic
- Use type hints where helpful

## 🐛 Bug Reports

When reporting bugs, please include:

1. Description of the issue
2. Steps to reproduce
3. Expected vs actual behavior
4. System information (OS, Python version)
5. Error messages / stack traces

## ✨ Feature Requests

For new features:

1. Describe the use case
2. Explain expected behavior
3. Consider implementation complexity
4. Check if it fits project scope

## 📚 Documentation

When changing functionality:

- Update README.md if user-facing
- Update docstrings in code
- Update tests
- Add examples if helpful

## 🔄 Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure they pass
5. Update documentation
6. Submit pull request

## 📜 License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT with extended terms).

## ❓ Questions?

Feel free to open an issue for questions or discussions!

---

**Thank you for contributing! 🙏**
