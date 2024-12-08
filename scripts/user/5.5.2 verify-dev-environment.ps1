# verify-dev-environment.ps1

Write-Host "Checking VS Code configuration..." -ForegroundColor Cyan

# Check VS Code settings
$vsCodeSettingsPath = Join-Path $env:USERPROFILE "DevConfig\\.vscode\\settings.json"
if (Test-Path $vsCodeSettingsPath) {
    Write-Host "✓ VS Code user settings found" -ForegroundColor Green

    # Validate JSON format
    try {
        Get-Content $vsCodeSettingsPath | ConvertFrom-Json
        Write-Host "✓ VS Code settings are valid JSON" -ForegroundColor Green
    } catch {
        Write-Error "VS Code settings contain invalid JSON"
    }
} else {
    Write-Error "VS Code user settings not found"
}

# Check VS Code extensions
Write-Host "`nVerifying VS Code extensions..." -ForegroundColor Cyan
$requiredExtensions = @(
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "GitHub.copilot",
    "GitHub.copilot-chat"
)

$installedExtensions = code --list-extensions
foreach ($extension in $requiredExtensions) {
    if ($installedExtensions -contains $extension) {
        Write-Host "✓ Extension installed: $extension" -ForegroundColor Green
    } else {
        Write-Error "Missing required extension: $extension"
    }
}
