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

# Create temporary directory for downloads
$tempDir = New-Item -ItemType Directory -Force -Path "$env:TEMP\dev-setup-$(Get-Random)"

try {
    Write-Host "Initializing development environment setup..." -ForegroundColor Cyan

    # Function to download a file from GitHub
    function Download-Script {
        param (
            [string]$RelativePath,
            [string]$TargetPath
        )
        $url = "$baseUrl/$RelativePath"
        $targetDir = Split-Path -Parent $TargetPath
        
        if (!(Test-Path $targetDir)) {
            New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        }
        
        Write-Host "Downloading $RelativePath..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $url -OutFile $TargetPath
        }
        catch {
            Write-Error "Failed to download $RelativePath : $_"
        }
    }

    # Create initial directory structure
    Write-Host "Creating directory structure..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path "$scriptsRoot\machine" | Out-Null
    New-Item -ItemType Directory -Force -Path "$scriptsRoot\user" | Out-Null

    # Define known scripts
    $scripts = @{
        "machine" = @(
            "4.1 create-machine-structure.ps1"
            "4.2.1 install-prerequisites.ps1"
            "4.2.2 install-core-tools.ps1"
            "4.3.1 configure-docker-machine.ps1"
            "4.3.2 verify-docker.ps1"
            "4.4 configure-shared-settings.ps1"
            "4.5 create-project-template.ps1"
        )
        "user" = @(
            "5.1.1 configure-onedrive-structure.ps1"
            "5.1.2 create-sync-ignores.ps1"
            "5.1.3 verify-onedrive-setup.ps1"
            "5.2.1 install-vscode-extensions.ps1"
            "5.2.2 configure-personal-tools.ps1"
            "5.3.1 configure-git-user.ps1"
            "5.3.2 configure-vscode-user.ps1"
            "5.3.3 configure-powershell-profile.ps1"
            "5.3.4 configure-npm-user.ps1"
            "5.3.5 verify-personal-settings.ps1"
            "5.4.1 configure-git-credentials.ps1"
            "5.4.2 setup-ssh-keys.ps1"
            "5.4.3 configure-npm-tokens.ps1"
            "5.4.4 setup-docker-credentials.ps1"
            "5.4.5 verify-credentials.ps1"
            "5.5.1 verify-git-setup.ps1"
            "5.5.2 verify-dev-environment.ps1"
            "5.5.3 verify-onedrive-sync.ps1"
            "5.5.4 verify-system.ps1"
        )
    }

    # Download all scripts
    foreach ($category in $scripts.Keys) {
        Write-Host "`nDownloading $category scripts..." -ForegroundColor Cyan
        foreach ($script in $scripts[$category]) {
            $relativePath = "scripts/$category/$script"
            $targetPath = "$scriptsRoot\$category\$script"
            Download-Script -RelativePath $relativePath -TargetPath $targetPath
        }
    }

    Write-Host "`nSetup scripts downloaded successfully!" -ForegroundColor Green
    Write-Host "Beginning environme
