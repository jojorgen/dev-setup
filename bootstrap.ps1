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
$baseUrl = "https://api.github.com/repos/$repoOwner/$repoName/contents"
$devRoot = "C:\Dev"
$scriptsRoot = "$devRoot\Scripts"

# Create temporary directory for downloads
$tempDir = New-Item -ItemType Directory -Force -Path "$env:TEMP\dev-setup-$(Get-Random)"

try {
    Write-Host "Initializing development environment setup..." -ForegroundColor Cyan

    # Function to download a file from GitHub
    function Download-Script {
        param (
            [string]$DownloadUrl,
            [string]$TargetPath
        )
        $targetDir = Split-Path -Parent $TargetPath
        
        if (!(Test-Path $targetDir)) {
            New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        }
        
        Write-Host "Downloading $(Split-Path $TargetPath -Leaf)..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $TargetPath
    }

    # Function to get repository contents recursively
    function Get-RepoContents {
        param (
            [string]$Path
        )
        
        $url = "$baseUrl/$Path"
        if ($Path) {
            $url = "$baseUrl/$Path?ref=$Branch"
        } else {
            $url = "$baseUrl`?ref=$Branch"
        }

        $response = Invoke-RestMethod -Uri $url
        return $response
    }

    # Create initial directory structure
    Write-Host "Creating directory structure..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $scriptsRoot | Out-Null

    # Get contents of scripts directory
    Write-Host "Fetching repository structure..." -ForegroundColor Yellow
    $scriptsContent = Get-RepoContents "scripts"

    # Process each category (machine, user)
    foreach ($item in $scriptsContent) {
        if ($item.type -eq "dir") {
            $categoryPath = $item.path
            $categoryName = Split-Path $categoryPath -Leaf
            Write-Host "Processing $categoryName scripts..." -ForegroundColor Cyan
            
            # Get all .ps1 files in this category
            $categoryContent = Get-RepoContents $categoryPath
            foreach ($file in $categoryContent) {
                if ($file.name -like "*.ps1") {
                    $targetPath = "$scriptsRoot\$categoryName\$($file.name)"
                    Download-Script -DownloadUrl $file.download_url -TargetPath $targetPath
                }
            }
        }
    }

    Write-Host "`nSetup scripts downloaded successfully!" -ForegroundColor Green
    Write-Host "Beginning environment setup..." -ForegroundColor Cyan

    # Find and run the first machine setup script (assumed to be the one starting with "4.1")
    $firstScript = Get-ChildItem "$scriptsRoot\machine\4.1*.ps1" | Select-Object -First 1
    if ($firstScript) {
        Write-Host "Starting machine setup with $($firstScript.Name)..." -ForegroundColor Cyan
        & $firstScript.FullName
    } else {
        Write-Warning "Could not find initial setup script in machine directory."
    }

} catch {
    Write-Error "An error occurred: $_"
} finally {
    # Cleanup
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}