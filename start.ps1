# Windows startup script
# This script configures necessary environment variables and starts the server

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Data Extraction and Ingestion" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "ERROR: .env file not found" -ForegroundColor Red
    Write-Host "Please copy .env.example to .env and configure your credentials" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Run: cp .env.example .env" -ForegroundColor Yellow
    exit 1
}

Write-Host "Loading environment variables from .env..." -ForegroundColor Green

# Load environment variables from .env
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^#].+?)=(.+)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        [Environment]::SetEnvironmentVariable($name, $value, 'Process')
        Write-Host "  ✓ $name configured" -ForegroundColor DarkGray
    }
}

# Configure UTF-8 encoding (critical on Windows)
Write-Host ""
Write-Host "Configuring UTF-8 encoding..." -ForegroundColor Green
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"
$env:LANG = "en_US.UTF-8"
$env:LC_ALL = "en_US.UTF-8"

# Set console code page to UTF-8
chcp 65001 | Out-Null

Write-Host "  ✓ PYTHONIOENCODING=utf-8" -ForegroundColor DarkGray
Write-Host "  ✓ PYTHONUTF8=1" -ForegroundColor DarkGray
Write-Host "  ✓ Console Code Page=65001 (UTF-8)" -ForegroundColor DarkGray

# Verify credentials
Write-Host ""
if (-not $env:LLAMA_CLOUD_API_KEY) {
    Write-Host "WARNING: LLAMA_CLOUD_API_KEY is not configured" -ForegroundColor Yellow
}
if (-not $env:LLAMA_CLOUD_PROJECT_ID) {
    Write-Host "WARNING: LLAMA_CLOUD_PROJECT_ID is not configured" -ForegroundColor Yellow
}

# Start the server
Write-Host ""
Write-Host "Starting LlamaAgents server..." -ForegroundColor Green
Write-Host "The application will be available at: http://localhost:8000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

try {
    uvx llamactl serve
} catch {
    Write-Host ""
    Write-Host "ERROR: Could not start the server" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible solutions:" -ForegroundColor Yellow
    Write-Host "  1. Verify that 'uv' is installed: uv --version" -ForegroundColor White
    Write-Host "  2. Verify that port 8000 is available" -ForegroundColor White
    Write-Host "  3. Check your credentials in .env" -ForegroundColor White
    Write-Host ""
    Write-Host "For more help, see DEPLOYMENT.md" -ForegroundColor Cyan
    exit 1
}
