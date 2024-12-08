# configure-git-credentials.ps1
$gitCredentialsPath = Join-Path $env:USERPROFILE ".config\git-credentials"

# Create and secure directory
if (!(Test-Path $gitCredentialsPath)) {
    New-Item -ItemType Directory -Force -Path $gitCredentialsPath | Out-Null
    
    # Secure the directory
    $acl = New-Object System.Security.AccessControl.DirectorySecurity
    $acl.SetAccessRuleProtection($true, $false)
    
    # Add current user
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
        "FullControl",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )
    $acl.AddAccessRule($rule)
    
    # Add SYSTEM
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "NT AUTHORITY\SYSTEM",
        "FullControl",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )
    $acl.AddAccessRule($rule)
    
    Set-Acl $gitCredentialsPath $acl
}

# Configure Git to use the credential manager
git config --global credential.helper manager-core
git config --global credential.credentialStore gpg

Write-Host "Git credential storage configured." -ForegroundColor Green

# Trigger authentication by testing connection to GitHub
git ls-remote https://github.com/microsoft/vscode.git HEAD 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Successfully authenticated with GitHub" -ForegroundColor Green
} else {
    Write-Host "`n! Authentication might not have completed successfully. Please verify by:" -ForegroundColor Yellow
    Write-Host "  1. Running: git fetch https://github.com/microsoft/vscode.git" -ForegroundColor Cyan
    Write-Host "  2. Check if you get prompted for authentication" -ForegroundColor Cyan
}