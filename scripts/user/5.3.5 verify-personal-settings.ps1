# verify-personal-settings.ps1

# Check Git configuration
Write-Host "Verifying Git configuration..." -ForegroundColor Cyan
git config --list --global | ForEach-Object {
    Write-Host "✓ $_" -ForegroundColor Green
}

# Check VS Code settings
$vscodePath = Join-Path $env:USERPROFILE "DevConfig\\.vscode\\settings.json"
if (Test-Path $vscodePath) {
    Write-Host "`n✓ VS Code settings found at: $vscodePath" -ForegroundColor Green
} else {
    Write-Error "VS Code settings not found"
}

# Check PowerShell profile
if (Test-Path $PROFILE.CurrentUserAllHosts) {
    Write-Host "`n✓ PowerShell profile configured" -ForegroundColor Green
} else {
    Write-Error "PowerShell profile not found"
}

# Check NPM config
$npmrcPath = Join-Path $env:USERPROFILE "DevConfig\\npm\\.npmrc"
if (Test-Path $npmrcPath) {
    Write-Host "`n✓ NPM configuration found at: $npmrcPath" -ForegroundColor Green
} else {
    Write-Error "NPM configuration not found"
}
