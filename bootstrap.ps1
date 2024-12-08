# bootstrap.ps1
param (
    [string]$Branch = "main"
)

# Ensure running as admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator"
    exit
}

$ErrorActionPreference = "Stop"

# Define base URLs and directories
$repoOwner = "jojorgen"
$repoName = "dev-setup"
$baseUrl = "https://raw.githubusercontent.com/$repoOwner/$repoName/$Branch"
$devRoot = "C:\Dev"
$scriptsRoot = "$devRoot\Scripts"

try {
    Write-Host "Initializing development environment setup..." -ForegroundColor Cyan

    # Create Scripts directory structure
    Write-Host "Creating directory structure..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path "$scriptsRoot\machine" | Out-Null
    New-Item -ItemType Directory -Force -Path "$scriptsRoot\user" | Out-Null

    # First download and run create-machine-structure.ps1
    Write-Host "Downloading initial setup script..." -ForegroundColor Yellow
    $url = "$baseUrl/scripts/machine/4.1 create-machine-structure.ps1"
    $targetPath = "$scriptsRoot\machine\4.1 create-machine-structure.ps1"
    
    Invoke-WebRequest -Uri $url -OutFile $targetPath
    Write-Host "Downloaded initial setup script" -ForegroundColor Green

    # Run the initial setup script
    if (Test-Path $targetPath) {
        Write-Host "Starting machine setup..." -ForegroundColor Cyan
        & $targetPath
    } else {
        Write-Error "Could not find initial setup script: $targetPath"
    }

} catch {
    Write-Error "An error occurred: $_"
}
