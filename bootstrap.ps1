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
    Write-Host "Creating Scripts directory structure..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path "$scriptsRoot\machine" | Out-Null
    New-Item -ItemType Directory -Force -Path "$scriptsRoot\user" | Out-Null

    # Download all scripts from each directory
    $scriptDirs = @("machine", "setup", "user", "utils")
    foreach ($dir in $scriptDirs) {
        Write-Host "Downloading $dir scripts..." -ForegroundColor Yellow
        # List files in the GitHub directory
        $filesUrl = "https://api.github.com/repos/$repoOwner/$repoName/contents/scripts/$dir"
        $files = Invoke-RestMethod -Uri $filesUrl
        
        foreach ($file in $files) {
            if ($file.name -like "*.ps1") {
                $url = "$baseUrl/scripts/$dir/$($file.name)"
                $targetPath = "$scriptsRoot\$dir\$($file.name)"
                Invoke-WebRequest -Uri $url -OutFile $targetPath
                Write-Host "Downloaded $($file.name)" -ForegroundColor Green
            }
        }
    }

    Write-Host "Scripts downloaded successfully!" -ForegroundColor Green
    Write-Host "Starting initial setup..." -ForegroundColor Cyan

    # Run the initial setup script
    $firstScript = "$scriptsRoot\machine\4.1 create-machine-structure.ps1"
    if (Test-Path $firstScript) {
        Write-Host "Running machine setup..." -ForegroundColor Cyan
        & $firstScript
    } else {
        Write-Error "Could not find initial setup script: $firstScript"
    }

} catch {
    Write-Error "An error occurred: $_"
}
