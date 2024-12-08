# setup-docker-credentials.ps1
$dockerConfigPath = Join-Path $env:USERPROFILE ".config\tokens\docker"

# Create directory if it doesn't exist
if (!(Test-Path $dockerConfigPath)) {
    New-Item -ItemType Directory -Force -Path $dockerConfigPath | Out-Null
}

Write-Host "Docker Desktop is ready to use." -ForegroundColor Green
Write-Host "Note: If you need to work with private images, you can sign in to Docker Hub through Docker Desktop at any time." -ForegroundColor Cyan