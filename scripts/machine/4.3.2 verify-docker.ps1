# verify-docker.ps1

function Test-DockerSetup {
    Write-Host "Starting Docker verification..." -ForegroundColor Cyan

    # Detect system architecture
    $systemInfo = systeminfo | findstr "System Type"
    $isArm64 = $systemInfo -match "ARM64"
    $archType = if ($isArm64) { "ARM64" } else { "x86_64" }
    $dockerArch = if ($isArm64) { "linux/arm64" } else { "linux/amd64" }

    Write-Host "`nDetected system architecture: $archType" -ForegroundColor Yellow

    # 1. Check Docker service
    Write-Host "`nChecking Docker service..." -ForegroundColor Yellow
    try {
        $dockerService = Get-Service -Name "com.docker.service" -ErrorAction Stop
        Write-Host "Docker service status: $($dockerService.Status)" -ForegroundColor Green
    }
    catch {
        Write-Error "Docker service not found. Is Docker Desktop installed?"
        return $false
    }

    # 2. Test hello-world container
    Write-Host "`nTesting hello-world container..." -ForegroundColor Yellow
    try {
        docker run --rm hello-world
        Write-Host "Hello-world container test passed" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to run hello-world container: $_"
        return $false
    }

    # 3. Test architecture-specific container
    Write-Host "`nTesting architecture-specific container..." -ForegroundColor Yellow
    try {
        docker run --rm --platform $dockerArch alpine:latest uname -m
        Write-Host "Architecture-specific container test passed" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to run architecture-specific container: $_"
        return $false
    }

    # 4. Test volume mounting
    Write-Host "`nTesting volume mounting..." -ForegroundColor Yellow
    try {
        # Create a test directory and file
        $testDir = "C:\DockerTest"
        if (!(Test-Path $testDir)) {
            New-Item -ItemType Directory -Path $testDir | Out-Null
        }
        "Test content" | Out-File "$testDir\test.txt"

        # Test mounting with architecture-specific Alpine
        docker run --rm --platform $dockerArch -v ${testDir}:/data alpine:latest ls /data
        Write-Host "Volume mounting test passed" -ForegroundColor Green

        # Cleanup
        Remove-Item -Path $testDir -Recurse -Force
    }
    catch {
        Write-Warning "Volume mounting test failed: $_"
        Write-Warning "You may need to configure file sharing in Docker Desktop settings."
    }

    # 5. Test Node.js container
    Write-Host "`nTesting Node.js container..." -ForegroundColor Yellow
    try {
        docker run --rm --platform $dockerArch node:lts-alpine node --version
        Write-Host "Node.js container test passed" -ForegroundColor Green
    }
    catch {
        Write-Warning "Node.js container test failed. This is not critical but may affect development workflows."
    }

    # 6. Test platform-specific development container
    Write-Host "`nTesting platform-specific development container..." -ForegroundColor Yellow
    if ($isArm64) {
        try {
            docker run --rm --platform linux/arm64 ubuntu:latest uname -m
            Write-Host "ARM64 development container test passed" -ForegroundColor Green
        }
        catch {
            Write-Warning "ARM64 development container test failed: $_"
        }
    } else {
        try {
            docker run --rm mcr.microsoft.com/windows/nanoserver:ltsc2022 cmd /c ver
            Write-Host "Windows container test passed" -ForegroundColor Green
        }
        catch {
            Write-Warning "Windows container test failed. This is not critical if using Linux containers."
        }
    }

    # 7. Check Docker Compose
    Write-Host "`nChecking Docker Compose..." -ForegroundColor Yellow
    try {
        docker compose version
        Write-Host "Docker Compose check passed" -ForegroundColor Green
    }
    catch {
        Write-Error "Docker Compose check failed: $_"
        return $false
    }

    # 8. Check Docker network
    Write-Host "`nChecking Docker networks..." -ForegroundColor Yellow
    try {
        docker network ls
        Write-Host "Network check passed" -ForegroundColor Green
    }
    catch {
        Write-Error "Network check failed: $_"
        return $false
    }

    # 9. Check WSL2 integration
    Write-Host "`nChecking WSL2 status..." -ForegroundColor Yellow
    try {
        wsl --status
        Write-Host "WSL2 check passed" -ForegroundColor Green
    }
    catch {
        Write-Warning "WSL2 status check failed. This might affect Docker performance."
    }

    Write-Host "`nDocker verification complete!" -ForegroundColor Green
    return $true
}

# Run the verification
$result = Test-DockerSetup

# Final status
if ($result) {
    Write-Host "`nDocker setup verification completed successfully!" -ForegroundColor Green
    
    # Architecture-specific recommendations
    $systemInfo = systeminfo | findstr "System Type"
    if ($systemInfo -match "ARM64") {
        Write-Host "`nRecommendations for ARM64 systems:" -ForegroundColor Cyan
        Write-Host "1. Always use the '--platform linux/arm64' flag when running containers for optimal performance"
        Write-Host "2. Some x86 containers may run slower due to emulation"
        Write-Host "3. Prefer ARM64-native images when available"
        Write-Host "4. For development, use ARM64-compatible base images (e.g., node:lts-alpine)"
    } else {
        Write-Host "`nRecommendations for x86_64 systems:" -ForegroundColor Cyan
        Write-Host "1. You can run both Windows and Linux containers"
        Write-Host "2. Use native platform images for best performance"
        Write-Host "3. Consider using Windows containers for .NET development"
    }
} else {
    Write-Host "`nDocker setup verification failed. Please check the errors above." -ForegroundColor Red
}

# Display Docker system info
Write-Host "`nSystem Information:" -ForegroundColor Cyan
docker system info