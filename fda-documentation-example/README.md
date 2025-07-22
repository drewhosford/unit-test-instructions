# FDA Documentation Generator

A Python script that automatically generates FDA-compliant documentation from test files across multiple programming languages using YAML configuration.

## Overview

The `create_fda_documentation.py` script parses test files in your repository, extracts requirements from test function names, and generates two types of FDA documentation:
1. **Requirements Documents** - Software requirements specifications
2. **Verification Documents** - Test verification protocols

## Features

- **Multi-language support**: Golang, Swift, Python, JavaScript, TypeScript, Java, C#
- **Automatic test file discovery**: Intelligently finds test files by analyzing imports
- **YAML configuration**: Clean, readable configuration format
- **Flexible project structure**: Works with any repository layout
- **FDA compliance**: Generates properly formatted requirements and verification documents

## Required Python Packages

Install dependencies with:
```bash
pip install -r requirements.txt
```

Required packages:
- `PyYAML>=6.0` - YAML configuration parsing
- `python-docx>=0.8.11` - Word document manipulation

## Configuration

The script uses a `config.yaml` file for configuration. Each section represents a different part of your project (backend, frontend, mobile, etc.).

### Configuration Structure

```yaml
backend:
  repo_path: ../golang-example  # REQUIRED - Repository root path to search for test files
  req_template_path: Templates/Software Requirements Specification - Backend.docx  # REQUIRED
  req_output_name: "Software Requirements Specification - Backend"  # REQUIRED
  ver_template_path: Templates/Verification Protocol - Backend.docx  # REQUIRED
  ver_output_name: "Verification Protocol - Backend"  # REQUIRED
  language: golang  # REQUIRED
  tag: API  # REQUIRED - Used in document tags [API:DO:1], [API:VER:1]
  sections:
    - display_name: "Users Endpoint"
      filename: "golang_example_test.go"
  ignore: []  # Optional: list of files to ignore

mobile:
  repo_path: ../swift-example  # REQUIRED - Repository root path to search for test files
  req_template_path: Templates/Software Requirements Specification - iOS App.docx  # REQUIRED
  req_output_name: "Software Requirements Specification - iOS App"  # REQUIRED
  ver_template_path: Templates/Verification Protocol - iOS App.docx  # REQUIRED
  ver_output_name: "Verification Protocol - iOS App"  # REQUIRED
  language: swift  # REQUIRED
  tag: IOS  # REQUIRED
  sections:
    - display_name: "Login Screen"
      filename: "LoginViewTests.swift"
  ignore: []  # Optional: list of files to ignore
```

### Required Fields

- `repo_path`: Repository root directory to search for test files
- `language`: Programming language (golang, swift, python, javascript, typescript, java, csharp)
- `tag`: Short identifier used in generated document tags
- `req_template_path`: Path to requirements document template
- `req_output_name`: Output name for requirements document
- `ver_template_path`: Path to verification document template  
- `ver_output_name`: Output name for verification document

## Test File Discovery

The script automatically discovers test files by:

1. **Recursive search**: Searches the entire `repo_path` directory tree
2. **Import detection**: Identifies test files by detecting testing framework imports
3. **Performance optimized**: Only reads the first 50 lines of each file for import detection
4. **Excludes common directories**: Automatically skips `.git`, `node_modules`, `__pycache__`, etc.

### Language-Specific Test Detection

| Language   | Test Import Patterns |
|------------|---------------------|
| Golang     | `import "testing"` |
| Swift      | `import XCTest`, `@testable import` |
| Python     | `import unittest`, `import pytest` |
| JavaScript | `jest`, `mocha`, `chai`, `describe(`, `it(` |
| TypeScript | `jest`, `mocha`, `chai`, `describe(`, `it(` |
| Java       | `import org.junit`, `@Test` |
| C#         | `using NUnit.Framework`, `[Test]` |

### Excluded Directories

The following directories are automatically excluded from search:
- `.git`
- `node_modules`
- `__pycache__`
- `.venv`, `venv`
- `build`, `dist`, `target`

## Supported Languages

| Language   | File Ext | Test Pattern | Comments | Tag Required |
|------------|----------|--------------|----------|--------------|
| Golang     | .go      | `func Test_` | `//`     | Yes          |
| Swift      | .swift   | `func test_` | `//`     | Yes          |
| Python     | .py      | `def test_`  | `#`      | Yes          |
| JavaScript | .js      | `it("` or `test("` | `//` | Yes          |
| TypeScript | .ts      | `it("` or `test("` | `//` | Yes          |
| Java       | .java    | `@Test` + `testMethod` | `//` | Yes          |
| C#         | .cs      | `[Test]` + `TestMethod` | `//` | Yes          |

## Test File Format

Test files should follow this format:

### Golang Example
```go
import "testing"

func Test_UserCanCreateAccount(t *testing.T) {
    // S1: Navigate to registration page
    // S2: Enter valid user information
    // S3: Click submit button
    // V1: User account is created successfully
    // V2: Confirmation email is sent
    // V3: User is redirected to dashboard
}
```

### Swift Example
```swift
import XCTest

func test_UserCanLogin() {
    // S1: Launch application
    // S2: Enter valid credentials
    // S3: Tap login button
    // V1: User is authenticated
    // V2: Dashboard is displayed
}
```

### Python Example
```python
import unittest

def test_user_can_update_profile(self):
    # S1: Navigate to profile page
    # S2: Update user information
    # S3: Save changes
    # V1: Profile is updated in database
    # V2: Success message is displayed
```

## Usage

### Automatic Processing (Recommended)
```bash
python create_fda_documentation.py
```
Processes all configured sections automatically based on their language settings.

## Benefits

1. **Simplified Configuration**: Single YAML file with clear structure
2. **Automatic Discovery**: Finds test files anywhere in the repository
3. **Language Awareness**: Uses language-specific patterns to identify tests
4. **Flexible Structure**: Works with any project structure
5. **FDA Compliance**: Generates properly formatted documentation
6. **Extensible**: Easy to add support for new languages

## Output

The script generates two types of documents:

1. **Requirements Document**: Contains formatted requirements extracted from test function names
2. **Verification Document**: Contains test steps and verification criteria organized in tables

Both documents use the specified templates and include:
- Proper FDA-style numbering (e.g., [API:DO:1], [API:VER:1])
- Section organization based on configuration
- Cross-references between requirements and verification steps

## Adding New Languages

To add support for a new language:

1. Add an entry to the `language_configs` dictionary in `get_language_config()`
2. Define appropriate regex patterns for test syntax
3. Add test import patterns for framework detection
4. Update your `config.yaml` with sections using the new language

Example for Rust:
```python
'rust': {
    'test_file_ext': '.rs',
    'regex_requirement': re.compile(r'^\s*#\[test\]\s*\n\s*fn\s+test_(.+?)\('),
    'regex_test_step': re.compile(r'\s*//\s*(S\d+:\s*.+)'),
    'regex_test_ver': re.compile(r'\s*//\s*(V\d+:\s*.+)'),
    'requirement_group': 1,
    'test_import_patterns': [
        re.compile(r'^\s*#\[test\]'),
        re.compile(r'^\s*#\[cfg\(test\)\]')
    ]
}
```
