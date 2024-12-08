# install-core-tools.ps1

# Ensure script is run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator"
    exit
}

# Function to install a Chocolatey package with verification
function Install-VerifyPackage {
    param (
        [string]$PackageName,
        [string]$VerifyCommand,
        [string]$VerifyPath = ""
    )
    
    # First check if it's already installed via Chocolatey
    $chocoList = choco list $PackageName --exact
    $isInstalled = $chocoList -match "^$PackageName\s"
    
    if ($isInstalled) {
        Write-Host "$PackageName is already installed. Checking for updates..." -ForegroundColor Yellow
        choco upgrade $PackageName -y
    } else {
        Write-Host "Installing $PackageName..." -ForegroundColor Cyan
        choco install $PackageName -y
    }

    # Special handling for nodejs-lts
    if ($PackageName -eq "nodejs-lts") {
        # Verify node
        $nodePath = "C:\Program Files\nodejs\node.exe"
        $npmPath = "C:\Program Files\nodejs\npm.cmd"
        
        if (Test-Path $nodePath) {
            try {
                $nodeVersion = & $nodePath --version
                Write-Host "Node.js verified successfully: $nodeVersion" -ForegroundColor Green
                
                # Verify npm using cmd.exe
                if (Test-Path $npmPath) {
                    $npmVersion = cmd /c npm --version
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "npm verified successfully: $npmVersion" -ForegroundColor Green
                        return $true
                    }
                }
            }
            catch {
                Write-Error "Verification failed: $_"
                return $false
            }
        }
        Write-Error "Node.js verification failed"
        return $false
    }

    # Special handling for docker-desktop
    if ($PackageName -eq "docker-desktop") {
        # Docker Desktop needs special handling as it requires a restart
        Write-Host "Docker Desktop installation may require a system restart." -ForegroundColor Yellow
        return $true
    }

    # Regular verification for other packages
    if ($VerifyPath -ne "") {
        if (!(Test-Path $VerifyPath)) {
            Write-Error "Failed to verify $PackageName installation at path: $VerifyPath"
            return $false
        }
    } elseif (!(Get-Command $VerifyCommand -ErrorAction SilentlyContinue)) {
        Write-Error "Failed to verify $PackageName installation command: $VerifyCommand"
        return $false
    }
    
    Write-Host "$PackageName verified successfully" -ForegroundColor Green
    return $true
}

# Function to refresh environment variables
function Update-Environment {
    Write-Host "Refreshing environment variables..." -ForegroundColor Cyan
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path($ChocolateyProfile)) {
        Import-Module "$ChocolateyProfile"
        refreshenv
    }
}

# Function to install global NPM packages
function Install-GlobalNpmPackages {
    param (
        [array]$Packages
    )
    
    Write-Host "Installing global NPM packages..." -ForegroundColor Cyan
    
    foreach ($package in $Packages) {
        Write-Host "Installing $package..." -ForegroundColor Yellow
        try {
            $result = cmd /c npm install -g $package 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "$package installed successfully" -ForegroundColor Green
            } else {
                Write-Error "Failed to install $package. Error: $result"
            }
        }
        catch {
            Write-Error "Failed to install $package. Error: $_"
        }
    }
}

# Define core tools to install
$tools = @(
    @{
        Name = "git"
        Verify = "git"
        VerifyPath = ""
    },
    @{
        Name = "github-desktop"
        Verify = ""
        VerifyPath = "$env:LOCALAPPDATA\GitHubDesktop\GitHubDesktop.exe"
    },
    @{
        Name = "vscode"
        Verify = "code"
        VerifyPath = ""
    },
    @{
        Name = "nodejs-lts"
        Verify = "node"
        VerifyPath = ""
    },
    @{
        Name = "python"
        Verify = "python"
        VerifyPath = ""
    },
    @{
        Name = "docker-desktop"
        Verify = "docker"
        VerifyPath = ""
        SpecialCase = $true
        PostInstallMessage = "Docker Desktop has been installed but requires a system restart before it can be used.`nPlease restart your computer to complete the Docker installation."
    }
)

# Install tools one by one, stopping on any failure
foreach ($tool in $tools) {
    Write-Host "`nProcessing $($tool.Name)..." -ForegroundColor Cyan
    $verifyResult = if ($tool.VerifyPath -ne "") {
        Install-VerifyPackage -PackageName $tool.Name -VerifyCommand "" -VerifyPath $tool.VerifyPath
    } else {
        Install-VerifyPackage -PackageName $tool.Name -VerifyCommand $tool.Verify
    }

    if (!$verifyResult) {
        if ($tool.SpecialCase) {
            Write-Host $tool.PostInstallMessage -ForegroundColor Yellow
            continue
        } else {
            Write-Error "Failed to install/verify $($tool.Name). Stopping installation process."
            exit 1
        }
    }
}

# Update environment variables after installations
Update-Environment

# Define global NPM packages to install
$npmPackages = @(
    "yarn",
    "typescript",
    "eslint"
)

# Install global NPM packages
Install-GlobalNpmPackages -Packages $npmPackages

# Add final Docker notice if applicable
if ($tools | Where-Object { $_.Name -eq 'docker-desktop' }) {
    Write-Host "`n=======================================" -ForegroundColor Yellow
    Write-Host "IMPORTANT: System restart required" -ForegroundColor Yellow
    Write-Host "Docker Desktop has been installed but requires a system restart before it can be used." -ForegroundColor Yellow
    Write-Host "Please restart your computer to complete the installation." -ForegroundColor Yellow
    Write-Host "=======================================`n" -ForegroundColor Yellow
}

Write-Host "`nCore tools installation complete!" -ForegroundColor Green

# Final verification summary
Write-Host "`nVerification Summary:" -ForegroundColor Cyan
foreach ($tool in $tools) {
    $name = $tool.Name
    Write-Host "Verifying $name..." -ForegroundColor Yellow
    try {
        switch ($name) {
            "nodejs-lts" {
                $version = & node --version
                Write-Host "Node.js version: $version" -ForegroundColor Green
                $npmVersion = cmd /c npm --version
                Write-Host "npm version: $npmVersion" -ForegroundColor Green
            }
            "git" { 
                $version = git --version
                Write-Host "$version" -ForegroundColor Green
            }
            "python" {
                $version = python --version
                Write-Host "$version" -ForegroundColor Green
            }
            "docker-desktop" {
                Write-Host "Docker Desktop installed - requires restart" -ForegroundColor Yellow
            }
            default {
                Write-Host "Installed" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Warning "Could not verify $name"
    }
}