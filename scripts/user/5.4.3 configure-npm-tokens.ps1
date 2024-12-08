# configure-npm-settings.ps1
$npmConfigPath = Join-Path $env:USERPROFILE ".config\npm\.npmrc"
$npmConfigDir = Split-Path $npmConfigPath -Parent

# Create directory if it doesn't exist
if (!(Test-Path $npmConfigDir)) {
    New-Item -ItemType Directory -Force -Path $npmConfigDir | Out-Null
}

# Create basic .npmrc with common settings
$npmConfig = @"
registry=https://registry.npmjs.org/
save-exact=true
init-license=MIT
"@

$npmConfig | Out-File -FilePath $npmConfigPath -Encoding utf8

Write-Host "Basic NPM configuration created at: $npmConfigPath" -ForegroundColor Green