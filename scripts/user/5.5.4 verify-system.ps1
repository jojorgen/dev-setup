# verify-system.ps1

Write-Host "Performing final system check..." -ForegroundColor Cyan

# Check essential commands
$commands = @(
    @{Name="git"; Command="git --version"},
    @{Name="node"; Command="node --version"},
    @{Name="npm"; Command="npm --version"},
    @{Name="code"; Command="code --version"},
    @{Name="docker"; Command="docker --version"}
)

foreach ($cmd in $commands) {
    try {
        $version = Invoke-Expression $cmd.Command
        Write-Host "✓ $($cmd.Name) is available: $version" -ForegroundColor Green
    } catch {
        Write-Error "$($cmd.Name) is not available"
    }
}

# Check environment variables
Write-Host "`nChecking environment variables..." -ForegroundColor Cyan
$path = $env:Path -split ';'
$requiredPaths = @(
    "Git",
    "NodeJS",
    "Microsoft VS Code"
)

foreach ($required in $requiredPaths) {
    if ($path | Where-Object { $_ -like "*$required*" }) {
        Write-Host "✓ Found $required in PATH" -ForegroundColor Green
    } else {
        Write-Warning "$required not found in PATH"
    }
}
