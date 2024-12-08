# create-project-template.ps1
# Ensure running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator"
    exit
}

# Base directory for project template
$templateDir = "C:\Dev\Projects\ProjectTemplate"

# Define directory structure
$dirs = @(
    ".vscode",
    ".github\workflows",
    "src\components",
    "src\services",
    "src\utils",
    "tests\unit",
    "tests\integration",
    "scripts",
    "docs"
)

# Create directories
foreach ($dir in $dirs) {
    $path = Join-Path $templateDir $dir
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path
        Write-Host "Created directory: $path" -ForegroundColor Green
    }
}

# Copy shared configurations
$sharedConfigRoot = "C:\Dev\Environment\Tools\configs"
# VS Code settings
Copy-Item (Join-Path $sharedConfigRoot "vscode\settings.json") (Join-Path $templateDir ".vscode\settings.json")

# Create VS Code extension recommendations
$vsCodeExtensions = @"
{
    "recommendations": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "eamodio.gitlens",
        "github.copilot",
        "ms-vsliveshare.vsliveshare"
    ]
}
"@
$vsCodeExtensions | Out-File -FilePath (Join-Path $templateDir ".vscode\extensions.json") -Encoding utf8

# Copy ESLint config
Copy-Item (Join-Path $sharedConfigRoot "eslint\.eslintrc.json") (Join-Path $templateDir ".eslintrc.json")

# Copy Prettier config
Copy-Item (Join-Path $sharedConfigRoot "prettier\.prettierrc.json") (Join-Path $templateDir ".prettierrc")

# Create GitHub Actions workflow for CI
$githubWorkflow = @"
name: CI Pipeline
on:
  push:
    branches: [ main, dev ]
  pull_request:
    branches: [ main, dev ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Use Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18.x'
      - run: npm ci
      - run: npm test
      - run: npm run lint
  
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Use Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18.x'
      - run: npm ci
      - run: npm run build
"@
$githubWorkflow | Out-File -FilePath (Join-Path $templateDir ".github\workflows\ci.yml") -Encoding utf8

# Create package.json
$packageJson = @"
{
    "name": "project-template",
    "version": "0.1.0",
    "private": true,
    "scripts": {
        "start": "react-scripts start",
        "build": "react-scripts build",
        "test": "react-scripts test",
        "eject": "react-scripts eject",
        "lint": "eslint .",
        "lint:fix": "eslint . --fix",
        "format": "prettier --write \"**/*.{js,jsx,ts,tsx,json,md}\""
    },
    "dependencies": {
        "react": "^18.2.0",
        "react-dom": "^18.2.0",
        "react-scripts": "5.0.1"
    },
    "devDependencies": {
        "@testing-library/jest-dom": "^6.1.4",
        "@testing-library/react": "^14.1.2",
        "@testing-library/user-event": "^14.5.1",
        "eslint": "^8.54.0",
        "eslint-config-prettier": "^9.0.0",
        "eslint-plugin-prettier": "^5.0.1",
        "eslint-plugin-react": "^7.33.2",
        "prettier": "^3.1.0"
    }
}
"@
$packageJson | Out-File -FilePath (Join-Path $templateDir "package.json") -Encoding utf8

# Create README template
$readme = @"
# Project Name

## Overview
Brief description of what this project does.

## Prerequisites
- Node.js (LTS)
- VS Code with recommended extensions

## Development Setup
1. Clone the repository
2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`
3. Start development server:
   \`\`\`bash
   npm start
   \`\`\`

## Testing
Run tests:
\`\`\`bash
npm test
\`\`\`

## Linting and Formatting
- Lint: \`npm run lint\`
- Fix lint issues: \`npm run lint:fix\`
- Format code: \`npm run format\`

## CI Pipeline
This project uses GitHub Actions for:
- Running tests
- Linting code
- Building the application

## Project Structure
\`\`\`
├── .github/        # GitHub Actions workflows
├── .vscode/        # VS Code settings
├── src/           
│   ├── components/ # React components
│   ├── services/   # API services
│   └── utils/      # Utilities
├── tests/         # Test files
└── docs/          # Documentation
\`\`\`
"@
$readme | Out-File -FilePath (Join-Path $templateDir "README.md") -Encoding utf8

Write-Host "`nProject template has been created successfully!" -ForegroundColor Green
Write-Host "Please verify the structure and configurations." -ForegroundColor Green