# setup-ssh-keys.ps1

# Ensure running as Administrator to manage services
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script needs to be run as Administrator to configure the SSH agent service."
    Write-Warning "Please run it again with administrative privileges."
    exit
}

$sshPath = Join-Path $env:USERPROFILE ".ssh"

# Create .ssh directory if it doesn't exist
if (!(Test-Path $sshPath)) {
    New-Item -ItemType Directory -Force -Path $sshPath
    # Secure the directory
    $acl = Get-Acl $sshPath
    $acl.SetAccessRuleProtection($true, $false)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
        "FullControl",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )
    $acl.AddAccessRule($rule)
    Set-Acl $sshPath $acl
}

# Setup SSH Agent Service
$sshAgentService = Get-Service -Name "ssh-agent" -ErrorAction SilentlyContinue
if ($null -eq $sshAgentService) {
    Write-Host "Installing OpenSSH Client..." -ForegroundColor Yellow
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
}

# Configure SSH Agent service
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service ssh-agent
Write-Host "SSH Agent service configured and started" -ForegroundColor Green

# Generate SSH key if it doesn't exist
$keyPath = Join-Path $sshPath "id_ed25519"
if (!(Test-Path $keyPath)) {
    $email = git config --global user.email
    ssh-keygen -t ed25519 -C $email -f $keyPath
    
    # Add key to agent
    ssh-add $keyPath
    
    # Display the public key
    Write-Host "`nYour SSH public key:" -ForegroundColor Cyan
    Get-Content "$keyPath.pub"
    Write-Host "`nAdd this public key to your GitHub account at: https://github.com/settings/keys" -ForegroundColor Yellow
    
    # Optional: Copy to clipboard
    if (Get-Command "Set-Clipboard" -ErrorAction SilentlyContinue) {
        Get-Content "$keyPath.pub" | Set-Clipboard
        Write-Host "Public key has been copied to clipboard" -ForegroundColor Green
    }
}

# Verify setup
Write-Host "`nVerifying SSH setup..." -ForegroundColor Cyan
$sshAgentRunning = Get-Service ssh-agent | Where-Object {$_.Status -eq "Running"}
if ($sshAgentRunning) {
    Write-Host "✓ SSH agent is running" -ForegroundColor Green
} else {
    Write-Error "SSH agent is not running"
}

if (Test-Path $keyPath) {
    Write-Host "✓ SSH key pair exists" -ForegroundColor Green
} else {
    Write-Error "SSH key pair was not created"
}