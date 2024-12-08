# verify-onedrive-setup.ps1
# Check OneDrive structure
$devConfigPath = Join-Path $oneDrivePath "DevConfig"

# Verify directories exist
$allDirs = @(
    ".vscode",
    "git",
    "powershell",
    "npm"
)

foreach ($dir in $allDirs) {
    $path = Join-Path $devConfigPath $dir
    if (Test-Path $path) {
        Write-Host "✓ Found $dir directory" -ForegroundColor Green
    } else {
        Write-Error "✗ Missing directory: $dir"
    }
}

# Verify sync status
Write-Host "`nChecking OneDrive sync status..."
Get-Process OneDrive -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "OneDrive is running" -ForegroundColor Green
}

# Check local config structure
$localConfigPath = Join-Path $env:USERPROFILE ".config"
$localDirs = @(
    "git-credentials",
    "tokens",
    "ai-tools"
)

foreach ($dir in $localDirs) {
    $path = Join-Path $localConfigPath $dir
    if (Test-Path $path) {
        Write-Host "✓ Found local $dir directory" -ForegroundColor Green
    } else {
        Write-Error "✗ Missing local directory: $dir"
    }
}