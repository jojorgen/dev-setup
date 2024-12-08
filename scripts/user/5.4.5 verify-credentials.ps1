# verify-credentials.ps1

# Check Git credential helper
Write-Host "Checking Git credential configuration..." -ForegroundColor Cyan
$gitCredHelper = git config --global credential.helper
if ($gitCredHelper -eq "manager-core") {
    Write-Host "✓ Git credential helper configured correctly" -ForegroundColor Green
} else {
    Write-Error "Git credential helper not properly configured"
}

# Check SSH setup
Write-Host "`nChecking SSH configuration..." -ForegroundColor Cyan
$sshKeyPath = Join-Path $env:USERPROFILE ".ssh\id_ed25519"
if (Test-Path $sshKeyPath) {
    Write-Host "✓ SSH key exists" -ForegroundColor Green
} else {
    Write-Error "SSH key not found"
}

# Check NPM configuration
Write-Host "`nChecking NPM configuration..." -ForegroundColor Cyan
$npmConfigPath = Join-Path $env:USERPROFILE ".config\npm\.npmrc"
if (Test-Path $npmConfigPath) {
    Write-Host "✓ NPM configuration exists" -ForegroundColor Green
} else {
    Write-Error "NPM configuration not found"
}