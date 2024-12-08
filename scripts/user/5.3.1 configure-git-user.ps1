# configure-git-user.ps1
$userEmail = Read-Host "Enter your Git email"
$userName = Read-Host "Enter your Git username"

# Configure user identity
git config --global user.email $userEmail
git config --global user.name $userName

# Configure default branch name
git config --global init.defaultBranch main

# Configure line endings
git config --global core.autocrlf true

# Configure merge and diff tools
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'

Write-Host "`nGit user configuration complete!" -ForegroundColor Green
