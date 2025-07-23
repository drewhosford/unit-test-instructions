# FDA Documentation Generator

A comprehensive tool for generating FDA-compliant documentation from unit tests across multiple programming languages.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Supported Languages](#supported-languages)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Examples](#examples)
- [Test Discovery](#test-discovery)
- [Migration Guide](#migration-guide)
- [Advanced Usage](#advanced-usage)

## Overview

The FDA Documentation Generator is an intelligent tool that automatically discovers test files in your repositories and generates professional FDA-compliant requirements and verification documents. It supports 8 programming languages and uses advanced import detection to identify test files without requiring manual configuration of test paths.

## Features

- **Multi-Language Support**: Supports Golang, Swift, Python, JavaScript, TypeScript, Java, C#, and Dart
- **Intelligent Test Discovery**: Automatically finds test files using framework import detection
- **Professional Output**: Generates Microsoft Word documents with proper formatting and styling
- **Template-Based**: Uses your existing Word templates to maintain consistent formatting
- **Organized Output**: Automatically creates and manages an "Outputs" folder
- **Configurable**: YAML-based configuration for easy management
- **Path Filtering**: Support for path-based section filtering
- **Flexible Configuration**: Custom config file paths supported

## Supported Languages

| Language   | File Extension | Test Frameworks | Import Detection |
|------------|----------------|-----------------|------------------|
| Golang     | `.go`          | testing         | `import "testing"` |
| Swift      | `.swift`       | XCTest          | `import XCTest`, `@testable import` |
| Python     | `.py`          | unittest, pytest | `import unittest`, `import pytest` |
| JavaScript | `.js`          | Jest, Mocha, Chai | `require/import jest/mocha/chai` |
| TypeScript | `.ts`          | Jest, Mocha, Chai | `import jest/mocha/chai` |
| Java       | `.java`        | JUnit, TestNG   | `import org.junit`, `@Test` |
| C#         | `.cs`          | NUnit, MSTest, xUnit | `using NUnit.Framework`, `[Test]` |
| Dart       | `.dart`        | test, flutter_test | `package:test/test.dart`, `package:flutter_test` |

## Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd unit-test-instructions/fda-documentation-example
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

## Configuration

Create a `config.yaml` file in the same directory as the script:

```yaml
# Example configuration for multiple repositories
mobile_app:
  language: swift
  repo_path: /path/to/mobile/repo
  tag: MOB
  req_template_path: templates/requirements_template.docx
  ver_template_path: templates/verification_template.docx
  req_output_name: mobile_requirements.docx
  ver_output_name: mobile_verification.docx
  sections:
    - display_name: "Authentication"
      filenames: ["AuthTests.swift"]
      path_key: "auth"
    - display_name: "User Interface"
      filenames: ["UITests.swift"]
  ignore: ["DeprecatedTests.swift"]

backend_api:
  language: golang
  repo_path: /path/to/backend/repo
  tag: API
  req_template_path: templates/requirements_template.docx
  ver_template_path: templates/verification_template.docx
  req_output_name: api_requirements.docx
  ver_output_name: api_verification.docx
  sections:
    - display_name: "User Management"
      filenames: ["user_test.go"]
    - display_name: "Data Processing"
      filenames: ["data_test.go"]

web_frontend:
  language: typescript
  repo_path: /path/to/frontend/repo
  tag: WEB
  req_template_path: templates/requirements_template.docx
  ver_template_path: templates/verification_template.docx
  req_output_name: web_requirements.docx
  ver_output_name: web_verification.docx
  sections:
    - display_name: "Components"
      filenames: ["component.test.ts"]
    - display_name: "Services"
      filenames: ["service.test.ts"]
```

### Required Configuration Fields

Each repository section must include:
- `language`: Programming language (required)
- `repo_path`: Path to repository root (required)
- `tag`: Identifier tag for requirements (required)
- `req_template_path`: Path to requirements template (required)
- `ver_template_path`: Path to verification template (required)
- `req_output_name`: Output filename for requirements (required)
- `ver_output_name`: Output filename for verification (required)

### Optional Configuration Fields

- `sections`: List of section configurations
- `ignore`: List of test files to ignore
- `path_key`: Filter tests by path substring

## Usage

### Basic Usage
```bash
python create_fda_documentation.py
```

### Using Custom Config File
```bash
python create_fda_documentation.py --config custom_config.yaml
python create_fda_documentation.py -c /path/to/config.yaml
```

## Examples

### Test File Format

Tests should follow this format with special comments for steps and verifications:

**Golang Example:**
```go
func Test_userCanLoginWithValidCredentials(t *testing.T) {
    // S1: Navigate to login screen
    // S2: Enter valid username and password
    // S3: Click login button
    // V1: User is redirected to dashboard
    // V2: Welcome message displays user's name
    // V3: Session token is stored securely
    
    // Test implementation here...
}
```

**Swift Example:**
```swift
func test_userCanLoginWithValidCredentials() throws {
    // S1: Launch the application
    // S2: Tap on login button
    // S3: Enter valid credentials
    // V1: Login screen disappears
    // V2: Main dashboard is displayed
    // V3: User profile shows correct information
    
    // Test implementation here...
}
```

**Python Example:**
```python
def test_user_can_login_with_valid_credentials(self):
    # S1: Open login page
    # S2: Fill in username field
    # S3: Fill in password field
    # S4: Click submit button
    # V1: Redirect to dashboard occurs
    # V2: Success message is displayed
    # V3: User session is created
    
    # Test implementation here...
```

## Test Discovery

The system uses intelligent test discovery that works by:

1. **File Extension Filtering**: Scans for files with the correct extension (`.go`, `.swift`, `.py`, etc.)
2. **Import Pattern Matching**: Analyzes the first 50 lines of each file for testing framework imports
3. **Framework Detection**: Identifies files containing testing-specific patterns

### Detected Patterns by Language

- **Golang**: `import "testing"`, `func Test_`
- **Swift**: `import XCTest`, `@testable import`, `class.*XCTestCase`
- **Python**: `import unittest`, `import pytest`, `class.*TestCase`
- **JavaScript/TypeScript**: `import/require jest/mocha`, `describe(`, `test(`
- **Java**: `import org.junit`, `@Test`, `@BeforeEach`
- **C#**: `using NUnit.Framework`, `[Test]`, `[TestMethod]`
- **Dart**: `package:test/test.dart`, `test(`, `testWidgets(`

## config.yaml format
```yaml
golang_project:
  language: golang
  repo_path: /path/to/repo
  tag: GO
  req_template_path: template.docx
  ver_template_path: verification_template.docx
  req_output_name: golang_requirements.docx
  ver_output_name: golang_verification.docx
  sections:
    - display_name: "Unit Tests"
      path_key: "UnitTests"
      filenames: ["*.swift"]
    - display_name: "Integration Tests"
      path_key: "IntegrationTests"
      filenames: ["*.swift"]
```

## Advanced Usage

### Path-Based Filtering

Use `path_key` to filter tests by directory structure:

### Custom Output Directory

All outputs are automatically saved to an "Outputs" folder created in the same directory as your templates.

### Template Customization

The tool preserves your Word template formatting:
- Table styles are copied from the last table in verification templates
- Custom styles are maintained
- Professional formatting is preserved

## Dependencies

Use the requirements file:

```bash
pip install -r requirements.txt
```

## Troubleshooting

### No Test Files Found
- Verify `repo_path` is correct and contains the fully qualified path
- Check that test files contain proper import statements
- Ensure file extensions match the language configuration

### Missing Templates
- Verify template paths exist and are accessible
- Check that templates are valid .docx files
- Ensure templates contain required styles

### Output Issues
- Check write permissions for the output directory
- Verify template files are not open in another application

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
