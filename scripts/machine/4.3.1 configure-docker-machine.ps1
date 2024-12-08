# configure-docker-machine.ps1
# Ensure script is run as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator"
    exit
}

# Basic Docker configuration for running tool containers
$daemonConfig = @{
    "builder" = @{
        "gc" = @{
            "enabled" = $true
            "defaultKeepStorage" = "10GB"
        }
    }
    "experimental" = $false
    "features" = @{
        "buildkit" = $true
    }
    "dns" = @(
        "8.8.8.8",
        "8.8.4.4"
    )
}

# Save daemon configuration
$dockerConfigPath = "C:\Dev\Environment\Docker"
$daemonConfig | ConvertTo-Json -Depth 10 | Set-Content "$dockerConfigPath\daemon.json"

Write-Host "Basic Docker configuration complete!" -ForegroundColor Green