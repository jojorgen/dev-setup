# 4.1 create-machine-structure.ps1

# Ensure running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator"
    exit
}

# Define base directory
$baseDir = "C:\Dev"

# Define the complete directory structure
$dirs = @(
    # Environment section
    "Environment\AITools",           # AI development environments
    "Environment\Docker",            # Docker configurations
    "Environment\Tools\configs",     # Development tool configurations
    
    # Scripts section
    "Scripts\machine",              # Machine-level setup scripts
    "Scripts\setup",                # Setup scripts
    "Scripts\user",                 # User-level scripts
    "Scripts\utils",                # Utility scripts
    
    # Projects section
    "Projects\.github",             # GitHub templates
    "Projects\Products\Agents",     # AI agent implementations
    "Projects\Products\Apps",       # Application projects
    "Projects\Products\Libraries",  # Reusable code libraries
    "Projects\ProjectTemplate",     # New project templates
    
    # Tools section
    "Tools\References"              # Documentation and examples
)

# Create directories
foreach ($dir in $dirs) {
    $path = Join-Path $baseDir $dir
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path
        Write-Host "Created directory: $path" -ForegroundColor Green
    } else {
        Write-Host "Directory already exists: $path" -ForegroundColor Yellow
    }
}

# Set appropriate permissions
$acl = Get-Acl $baseDir
$inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
$propagationFlag = [System.Security.AccessControl.PropagationFlags]::None
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "Users",
    "Modify", 
    $inheritanceFlag,
    $propagationFlag,
    "Allow"
)
$acl.SetAccessRule($accessRule)
Set-Acl $baseDir $acl

Write-Host "`nDirectory structure created successfully!" -ForegroundColor Green

# Create a .gitignore file in the root directory
$gitignorePath = Join-Path $baseDir ".gitignore"
$gitignoreContent = @"
# Windows system files
[Tt]humbs.db
*.DS_Store

# Visual Studio Code
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

# Node.js
node_modules/
npm-debug.log
yarn-debug.log
yarn-error.log

# Build outputs
[Bb]in/
[Oo]bj/
[Dd]ist/
[Bb]uild/

# Environment files
.env
.env.local
.env.*.local

# IDE files
*.suo
*.user
*.userosscache
*.sln.docstates
.idea/

# Logs
logs/
*.log

# Temporary files
*.tmp
*~

# AI tool specific
.cursor/
.better-bolt/
"@

$gitignoreContent | Out-File -FilePath $gitignorePath -Encoding utf8
Write-Host "Created .gitignore file at: $gitignorePath" -ForegroundColor Green

Write-Host "`nNote:" -ForegroundColor Cyan
Write-Host "Development tools that come with their own installers" -ForegroundColor Yellow
Write-Host "(e.g., VS Code, GitHub Desktop) will be installed in their" -ForegroundColor Yellow
Write-Host "default Windows locations, not in this directory structure." -ForegroundColor Yellow

Write-Host "`nVerification steps:" -ForegroundColor Cyan
Write-Host "1. Check directory structure using: tree C:\Dev /F" -ForegroundColor Yellow
Write-Host "2. Verify permissions using: Get-Acl C:\Dev | Format-List" -ForegroundColor Yellow
Write-Host "3. Review .gitignore content" -ForegroundColor Yellow
