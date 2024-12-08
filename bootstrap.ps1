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

    # Create Scripts directory
    Write-Host "Creating directory structure..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $scriptsRoot | Out-Null

    # Download and process machine scripts
    Write-Host "Downloading machine scripts..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path "$scriptsRoot\machine" | Out-Null
    $machineFiles = (Invoke-WebRequest -Uri "https://github.com/jojorgen/dev-setup/tree/main/scripts/machine").Links.href |
        Where-Object { $_ -like "*.ps1" } |
        ForEach-Object { $_.Split('/')[-1] }
    
    foreach ($file in $machineFiles) {
        $url = "$baseUrl/scripts/machine/$file"
        $targetPath = "$scriptsRoot\machine\$file"
        Invoke-WebRequest -Uri $url -OutFile $targetPath
        Write-Host "Downloaded $file" -ForegroundColor Green
    }

    # Download and process user scripts
    Write-Host "`nDownloading user scripts..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path "$scriptsRoot\user" | Out-Null
    $userFiles = (Invoke-WebRequest -Uri "https://github.com/jojorgen/dev-setup/tree/main/scripts/user").Links.href |
        Where-Object { $_ -like "*.ps1" } |
        ForEach-Object { $_.Split('/')[-1] }
    
    foreach ($file in $userFiles) {
        $url = "$baseUrl/scripts/user/$file"
        $targetPath = "$scriptsRoot\user\$file"
        Invoke-WebRequest -Uri $url -OutFile $targetPath
        Write-Host "Downloaded $file" -ForegroundColor Green
    }

    Write-Host "`nSetup scripts downloaded successfully!" -ForegroundColor Green
    Write-Host "Beginning environment setup..." -ForegroundColor Cyan

    # Start with machine setup
    $firstScript = Get-ChildItem "$scriptsRoot\machine\4.1*.ps1" | Select-Object -First 1
    if ($firstScript) {
        Write-Host "Starting machine setup with $($firstScript.Name)..." -ForegroundColor Cyan
        & $firstScript.FullName
    } else {
        Write-Warning "Could not find initial setup script in machine directory."
    }

} catch {
    Write-Error "An error occurred: $_"
}
