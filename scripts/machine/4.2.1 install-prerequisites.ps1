# install-prerequisites.ps1

# Ensure script is run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator"
    exit
}

# Check current execution policies
Write-Host "Checking current execution policies..." -ForegroundColor Cyan
Write-Host "Current execution policy settings:" -ForegroundColor Yellow
Get-ExecutionPolicy -List | Format-Table -AutoSize

# Set execution policy for relevant scopes
Write-Host "Configuring PowerShell execution policies..." -ForegroundColor Cyan
$relevantScopes = @("Process", "CurrentUser", "LocalMachine")
foreach ($scope in $relevantScopes) {
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -Scope $scope
        Write-Host "Successfully set RemoteSigned policy for $scope scope" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not set execution policy for $scope scope" -ForegroundColor Yellow
    }
}

# Verify final execution policy settings
Write-Host "`nVerifying execution policy settings:" -ForegroundColor Cyan
Get-ExecutionPolicy -List | Format-Table -AutoSize

# Verify effective execution policy
$effectivePolicy = Get-ExecutionPolicy
Write-Host "Effective execution policy: $effectivePolicy" -ForegroundColor Yellow

if ($effectivePolicy -eq 'Restricted') {
    Write-Error "Execution policy is still restricted. Script execution may fail."
    Write-Host "Please run 'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force' manually." -ForegroundColor Red
    exit 1
}

# Install Chocolatey if not already installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey package manager..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    
    # Reload PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

Write-Host "Prerequisites installation complete!" -ForegroundColor Green