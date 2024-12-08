# verify-onedrive-sync.ps1

Write-Host "Checking OneDrive configuration..." -ForegroundColor Cyan

# Get OneDrive path
$oneDrivePath = [Environment]::GetEnvironmentVariable('OneDriveCommercial', 'User')
if (-not $oneDrivePath) {
    $oneDrivePath = [Environment]::GetEnvironmentVariable('OneDrive', 'User')
}

if ($oneDrivePath) {
    Write-Host "✓ OneDrive path found: $oneDrivePath" -ForegroundColor Green

    # Check DevConfig directory
    $devConfigPath = Join-Path $oneDrivePath "DevConfig"
    if (Test-Path $devConfigPath) {
        Write-Host "✓ DevConfig directory exists" -ForegroundColor Green

        # Check essential subdirectories
        $requiredDirs = @(".vscode", "git", "powershell", "npm")
        foreach ($dir in $requiredDirs) {
            $path = Join-Path $devConfigPath $dir
            if (Test-Path $path) {
                Write-Host "✓ Found $dir directory" -ForegroundColor Green
            } else {
                Write-Error "Missing directory: $dir"
            }
        }
    } else {
        Write-Error "DevConfig directory not found in OneDrive"
    }
} else {
    Write-Error "OneDrive path not found"
}

# Check OneDrive process
$oneDriveProcess = Get-Process "OneDrive" -ErrorAction SilentlyContinue
if ($oneDriveProcess) {
    Write-Host "✓ OneDrive is running" -ForegroundColor Green
} else {
    Write-Error "OneDrive is not running"
}
