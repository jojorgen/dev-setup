# create-sync-ignores.ps1
$gitignorePath = Join-Path $devConfigPath ".gitignore"
$gitignoreContent = @"
# Temp files
*.tmp
~$*
.DS_Store

# VS Code workspace files
*.code-workspace

# NPM cache
.npm/
"@

$gitignoreContent | Out-File -FilePath $gitignorePath -Encoding utf8