# configure-vscode-user.ps1
$vsCodeUserSettings = @{
    # Editor preferences
    "editor.fontFamily" = "Cascadia Code, Consolas, 'Courier New', monospace"
    "editor.fontSize" = 14
    "editor.lineHeight" = 20
    "editor.bracketPairColorization.enabled" = $true
    "editor.guides.bracketPairs" = "active"
    
    # Workbench settings
    "workbench.startupEditor" = "none"
    "workbench.colorTheme" = "One Dark Pro"
    "workbench.iconTheme" = "material-icon-theme"
    
    # Terminal settings
    "terminal.integrated.defaultProfile.windows" = "PowerShell"
    "terminal.integrated.fontFamily" = "CascadiaCode NF"
    
    # Git settings
    "git.enableSmartCommit" = $true
    "git.confirmSync" = $false
    
    # File handling
    "files.trimTrailingWhitespace" = $true
    "files.insertFinalNewline" = $true
}

# Ensure directory exists
$vsCodeSettingsDir = Join-Path $env:USERPROFILE "DevConfig\.vscode"
if (!(Test-Path $vsCodeSettingsDir)) {
    New-Item -ItemType Directory -Force -Path $vsCodeSettingsDir
}

$vsCodeSettingsPath = Join-Path $vsCodeSettingsDir "settings.json"
$vsCodeUserSettings | ConvertTo-Json -Depth 10 | Out-File $vsCodeSettingsPath -Encoding utf8

Write-Host "VS Code user settings configured at: $vsCodeSettingsPath" -ForegroundColor Green