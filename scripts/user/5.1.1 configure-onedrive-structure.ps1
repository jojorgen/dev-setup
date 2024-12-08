# configure-onedrive-structure.ps1
# Ensure running with user context (no admin required)

# Get OneDrive path from environment
$oneDrivePath = [Environment]::GetEnvironmentVariable('OneDriveCommercial', 'User')
if (-not $oneDrivePath) {
    $oneDrivePath = [Environment]::GetEnvironmentVariable('OneDrive', 'User')
}

if (-not $oneDrivePath) {
    Write-Error "OneDrive path not found. Please ensure OneDrive is set up and running."
    exit 1
}

# Define DevConfig structure in OneDrive
$devConfigPath = Join-Path $oneDrivePath "DevConfig"
$configDirs = @(
    ".vscode",
    "git",
    "powershell",
    "npm"
)

# Create DevConfig directory structure
foreach ($dir in $configDirs) {
    $path = Join-Path $devConfigPath $dir
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path
        Write-Host "Created directory: $path" -ForegroundColor Green
    }
}

# Create local .config structure
$localConfigPath = Join-Path $env:USERPROFILE ".config"
$localDirs = @(
    "git-credentials",
    "tokens",
    "ai-tools"
)

# Create local configuration directories
foreach ($dir in $localDirs) {
    $path = Join-Path $localConfigPath $dir
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path
        Write-Host "Created directory: $path" -ForegroundColor Green
    }
}

Write-Host "`nFolder structure setup complete!" -ForegroundColor Green