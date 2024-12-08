# verify-git-setup.ps1

Write-Host "Checking Git configuration..." -ForegroundColor Cyan

# Check Git global config
$requiredConfigs = @(
    @{Name="user.name"; Message="Git username"},
    @{Name="user.email"; Message="Git email"},
    @{Name="core.editor"; Message="Default editor"},
    @{Name="init.defaultBranch"; Message="Default branch"},
    @{Name="credential.helper"; Message="Credential helper"}
)

foreach ($config in $requiredConfigs) {
    $value = git config --global $config.Name
    if ($value) {
        Write-Host "✓ $($config.Message): $value" -ForegroundColor Green
    } else {
        Write-Error "Missing $($config.Message)"
    }
}

# Test GitHub access
Write-Host "`nTesting GitHub access..." -ForegroundColor Cyan
git ls-remote https://github.com/microsoft/vscode.git HEAD 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ GitHub access verified" -ForegroundColor Green
} else {
    Write-Error "GitHub access failed"
}