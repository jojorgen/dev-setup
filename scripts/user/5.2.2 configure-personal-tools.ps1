# configure-personal-tools.ps1
$userConfigPath = Join-Path $env:USERPROFILE "DevConfig"

# Create necessary directories if they don't exist
$vsCodePath = Join-Path $userConfigPath ".vscode"
if (!(Test-Path $vsCodePath)) {
    New-Item -ItemType Directory -Force -Path $vsCodePath
    Write-Host "Created directory: $vsCodePath" -ForegroundColor Green
}

# VS Code User Settings
$vsCodeSettings = @{
    "editor.formatOnSave" = $true
    "editor.defaultFormatter" = "esbenp.prettier-vscode"
    "editor.codeActionsOnSave" = @{
        "source.fixAll.eslint" = $true
    }
    "editor.rulers" = @(80, 100)
    "files.autoSave" = "onFocusChange"
    # Add more personal preferences here
}

$vsCodeSettingsPath = Join-Path $vsCodePath "settings.json"
$vsCodeSettings | ConvertTo-Json -Depth 10 | Out-File $vsCodeSettingsPath -Encoding utf8
Write-Host "VS Code settings configured at: $vsCodeSettingsPath" -ForegroundColor Green

# Configure git user settings
git config --global core.editor "code --wait"
git config --global pull.rebase false

Write-Host "Personal development tools configured!" -ForegroundColor Green

# Verify configuration
if (Test-Path $vsCodeSettingsPath) {
    Write-Host "✓ VS Code settings file created successfully" -ForegroundColor Green
} else {
    Write-Error "Failed to create VS Code settings file"
}