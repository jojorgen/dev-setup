# configure-powershell-profile.ps1
$profilePath = Join-Path $env:USERPROFILE "DevConfig\\powershell\\Microsoft.PowerShell_profile.ps1"
$profileDir = Split-Path $profilePath -Parent

# Create profile directory if it doesn't exist
if (!(Test-Path $profileDir)) {
    New-Item -ItemType Directory -Force -Path $profileDir
}

# Create PowerShell profile
$profileContent = @"
# Customize prompt
function prompt {
    `$currentPath = Get-Location
    `$gitBranch = git branch --show-current 2>`$null
    `$promptText = "PS `$currentPath"
    if (`$gitBranch) {
        `$promptText += " [`$gitBranch]"
    }
    return "`$promptText> "
}

# Aliases
Set-Alias -Name g -Value git
Set-Alias -Name c -Value code

# Helper functions
function gst { git status }
function gpl { git pull }
function gps { git push }
function gcm { git commit -m `$args[0] }

# Development shortcuts
function dev { Set-Location C:\\Dev }
function proj { Set-Location C:\\Dev\\Projects }

# Load other custom scripts if they exist
`$customScriptsPath = Join-Path `$PSScriptRoot 'custom'
if (Test-Path `$customScriptsPath) {
    Get-ChildItem -Path `$customScriptsPath -Filter '*.ps1' | ForEach-Object {
        . `$_.FullName
    }
}
"@

$profileContent | Out-File -FilePath $profilePath -Encoding utf8

# Create link to profile in PowerShell default location
$defaultProfilePath = $PROFILE.CurrentUserAllHosts
$defaultProfileDir = Split-Path $defaultProfilePath -Parent

if (!(Test-Path $defaultProfileDir)) {
    New-Item -ItemType Directory -Force -Path $defaultProfileDir
}

# Create a dot-sourcing profile that loads from DevConfig
$linkContent = ". '$profilePath'"
$linkContent | Out-File -FilePath $defaultProfilePath -Encoding utf8
