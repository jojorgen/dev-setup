# configure-shared-settings.ps1

# Ensure script is run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator"
    exit
}

# Define shared configuration root
$sharedConfigRoot = "C:\Dev\Environment\Tools\configs"

# Create configuration directories
$configDirs = @(
    "git",
    "vscode",
    "eslint",
    "prettier"
)

foreach ($dir in $configDirs) {
    $path = Join-Path $sharedConfigRoot $dir
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path
        Write-Host "Created directory: $path" -ForegroundColor Green
    }
}

# 1. Shared Git Configuration
$gitConfig = @"
[core]
    autocrlf = true
    safecrlf = false
    editor = code --wait
[init]
    defaultBranch = main
[pull]
    rebase = false
[fetch]
    prune = true
[protocol "https"]
    sslVerify = true
"@

$gitConfig | Out-File -FilePath (Join-Path $sharedConfigRoot "git\gitconfig") -Encoding utf8

# 2. Shared VS Code Settings
$vsCodeSettings = @"
{
    "files.encoding": "utf8",
    "files.eol": "\n",
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "editor.formatOnSave": true,
    "editor.rulers": [80, 100],
    "editor.tabSize": 2,
    "editor.detectIndentation": false,
    "editor.renderWhitespace": "boundary",
    "files.exclude": {
        "**/.git": true,
        "**/node_modules": true,
        "**/dist": true,
        "**/build": true
    }
}
"@

$vsCodeSettings | Out-File -FilePath (Join-Path $sharedConfigRoot "vscode\settings.json") -Encoding utf8

# 3. Shared ESLint Configuration
$eslintConfig = @"
{
    "root": true,
    "env": {
        "browser": true,
        "es2021": true,
        "node": true
    },
    "extends": [
        "eslint:recommended",
        "plugin:react/recommended"
    ],
    "parserOptions": {
        "ecmaVersion": "latest",
        "sourceType": "module",
        "ecmaFeatures": {
            "jsx": true
        }
    },
    "settings": {
        "react": {
            "version": "detect"
        }
    },
    "rules": {
        "indent": ["error", 2],
        "linebreak-style": ["error", "windows"],
        "quotes": ["error", "single"],
        "semi": ["error", "always"],
        "no-console": ["warn"],
        "react/react-in-jsx-scope": "off"
    }
}
"@

$eslintConfig | Out-File -FilePath (Join-Path $sharedConfigRoot "eslint\.eslintrc.json") -Encoding utf8

# 4. Shared Prettier Configuration
$prettierConfig = @"
{
    "printWidth": 80,
    "tabWidth": 2,
    "useTabs": false,
    "semi": true,
    "singleQuote": true,
    "trailingComma": "es5",
    "bracketSpacing": true,
    "jsxBracketSameLine": false,
    "arrowParens": "avoid",
    "endOfLine": "crlf"
}
"@

$prettierConfig | Out-File -FilePath (Join-Path $sharedConfigRoot "prettier\.prettierrc.json") -Encoding utf8

Write-Host "`nShared configurations have been set up successfully!" -ForegroundColor Green