# Enhanced install-vscode-extensions.ps1

function Find-VSCodeInstallations {
    $possibleLocations = @(
        # User installation paths
        [System.IO.Path]::Combine($env:LOCALAPPDATA, "Programs", "Microsoft VS Code", "bin", "code.cmd"),
        # System installation paths
        [System.IO.Path]::Combine($env:ProgramFiles, "Microsoft VS Code", "bin", "code.cmd"),
        # Common alternative editors based on VS Code
        [System.IO.Path]::Combine($env:LOCALAPPDATA, "Programs", "cursor", "resources", "app", "bin", "code.cmd")
    )
    
    $foundInstallations = @()
    
    foreach ($location in $possibleLocations) {
        if (Test-Path $location) {
            $version = $null
            $arch = $null
            try {
                # First try getting version directly from Code.exe
                $codePath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($location), "..", "Code.exe")
                if (Test-Path $codePath) {
                    $binaryInfo = Get-Item $codePath
                    $version = $binaryInfo.VersionInfo.ProductVersion
                    if ($binaryInfo.VersionInfo.FileDescription -match 'arm64') {
                        $arch = 'arm64'
                    } elseif ($binaryInfo.VersionInfo.FileDescription -match '64-bit') {
                        $arch = 'x64'
                    } else {
                        $arch = 'x86'
                    }
                }
                
                # If that fails, try command line version
                if (-not $version) {
                    $process = Start-Process -FilePath $location -ArgumentList "--version" -Wait -NoNewWindow -RedirectStandardOutput "version.txt" -PassThru
                    if ($process.ExitCode -eq 0) {
                        $versionOutput = Get-Content "version.txt" -First 1
                        if ($versionOutput -match '(\d+\.\d+\.\d+)') {
                            $version = $matches[1]
                        }
                    }
                    Remove-Item "version.txt" -ErrorAction SilentlyContinue
                }
                
                # If we still don't have a version, try one last method
                if (-not $version) {
                    $parentDir = [System.IO.Path]::GetDirectoryName([System.IO.Path]::GetDirectoryName($location))
                    $productJson = Join-Path $parentDir "resources\app\product.json"
                    if (Test-Path $productJson) {
                        $productInfo = Get-Content $productJson | ConvertFrom-Json
                        $version = $productInfo.version
                    }
                }
            } catch {
                Write-Warning "Could not get version info for $location : $_"
                continue
            }
            
            # Skip if we couldn't get any version info
            if (-not $version) {
                Write-Warning "Could not determine version for $location"
                continue
            }
            
            $installType = if ($location -match "cursor") { "Cursor" } else { "VS Code" }
            
            $foundInstallations += [PSCustomObject]@{
                Path = $location
                Version = $version
                Architecture = $arch
                Type = $installType
            }
        }
    }
    
    return $foundInstallations
}

function Install-VSCodeExtension {
    param (
        [string]$ExtensionId,
        [string]$CodePath,
        [switch]$Force
    )
    
    Write-Host "Installing VS Code extension: $ExtensionId" -ForegroundColor Cyan
    
    try {
        $args = @("--install-extension", $ExtensionId)
        if ($Force) {
            $args += "--force"
        }
        
        $process = Start-Process -FilePath $CodePath -ArgumentList $args -Wait -NoNewWindow -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Host "Successfully installed $ExtensionId" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Failed to install $ExtensionId" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Error "Error installing $ExtensionId : $_"
        return $false
    }
}

# Find all VS Code installations
$installations = Find-VSCodeInstallations

if ($installations.Count -eq 0) {
    Write-Error "No VS Code installations found!"
    exit 1
}

# If multiple installations found, let user choose
$selectedInstallation = if ($installations.Count -eq 1) {
    $installations[0]
} else {
    Write-Host "`nMultiple VS Code installations found:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $installations.Count; $i++) {
        Write-Host "$($i + 1). $($installations[$i].Type) v$($installations[$i].Version) ($($installations[$i].Architecture))"
    }
    
    do {
        $selection = Read-Host "`nSelect installation (1-$($installations.Count))"
    } while ([int]$selection -lt 1 -or [int]$selection -gt $installations.Count)
    
    $installations[[int]$selection - 1]
}

Write-Host "`nUsing $($selectedInstallation.Type) v$($selectedInstallation.Version) ($($selectedInstallation.Architecture))" -ForegroundColor Cyan

# Define extensions to install
$extensions = @(
    # Basic Development
    "ms-python.python",                    # Python
    "ms-vscode.powershell",               # PowerShell
    
    # Code Quality
    "dbaeumer.vscode-eslint",             # ESLint
    "esbenp.prettier-vscode",             # Prettier
    
    # Git
    "eamodio.gitlens",                    # GitLens
    
    # Docker
    "ms-azuretools.vscode-docker",        # Docker
    
    # General Utilities
    "EditorConfig.EditorConfig",          # EditorConfig
    "streetsidesoftware.code-spell-checker", # Code Spell Checker
    
    # Icons
    "vscode-icons-team.vscode-icons",     # VSCode Icons
    "PKief.material-icon-theme"           # Material Icon Theme
)

# Track installation results
$results = @{
    Successful = @()
    Failed = @()
}

# Install each extension
foreach ($extension in $extensions) {
    if (Install-VSCodeExtension -ExtensionId $extension -CodePath $selectedInstallation.Path -Force) {
        $results.Successful += $extension
    } else {
        $results.Failed += $extension
    }
}

# Display summary
Write-Host "`nInstallation Summary:" -ForegroundColor Cyan
Write-Host "Successfully installed:" -ForegroundColor Green
$results.Successful | ForEach-Object { Write-Host "  - $_" }
if ($results.Failed.Count -gt 0) {
    Write-Host "`nFailed to install:" -ForegroundColor Red
    $results.Failed | ForEach-Object { Write-Host "  - $_" }
}

# Note about GitHub Copilot
Write-Host "`nNote: GitHub Copilot extensions should be installed manually through VS Code:" -ForegroundColor Yellow
Write-Host "1. Open VS Code" -ForegroundColor Yellow
Write-Host "2. Click the Extensions icon (Ctrl+Shift+X)" -ForegroundColor Yellow
Write-Host "3. Search for 'GitHub Copilot' and install both:" -ForegroundColor Yellow
Write-Host "   - GitHub Copilot" -ForegroundColor Yellow
Write-Host "   - GitHub Copilot Chat" -ForegroundColor Yellow

# Check if VS Code is running
$vsCodeProcesses = Get-Process code -ErrorAction SilentlyContinue
if ($vsCodeProcesses) {
    Write-Host "`nWould you like to close all VS Code windows now? (y/n)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -eq 'y') {
        Get-Process code | Stop-Process
        Write-Host "VS Code has been closed. Please restart it manually." -ForegroundColor Green
    }
}