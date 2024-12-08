# configure-npm-user.ps1
$npmConfigPath = Join-Path $env:USERPROFILE "DevConfig\\npm\\.npmrc"
$npmConfigDir = Split-Path $npmConfigPath -Parent

# Create npm config directory if it doesn't exist
if (!(Test-Path $npmConfigDir)) {
    New-Item -ItemType Directory -Force -Path $npmConfigDir
}

# Basic npm configurations (non-auth)
$npmConfig = @"
save-exact=true
init-author-name=`"$((git config --global user.name).Trim())`"
init-author-email=`"$((git config --global user.email).Trim())`"
init-version=0.1.0
init-license=MIT
"@

$npmConfig | Out-File -FilePath $npmConfigPath -Encoding utf8
