# Deployment Guide - Requirements Architect

This guide provides detailed instructions for deploying the Requirements Architect application in different environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Initial Configuration](#initial-configuration)
- [Local Deployment](#local-deployment)
- [Production Deployment](#production-deployment)
- [Common Troubleshooting](#common-troubleshooting)
- [Maintenance](#maintenance)

## Prerequisites

### Required Software

1. **Python 3.12+**
   ```bash
   python --version
   # Should show Python 3.12 or higher
   ```

2. **uv** (Package manager)
   ```bash
   # Windows (PowerShell)
   powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
   
   # Linux/Mac
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

3. **Node.js and pnpm** (for UI development)
   ```bash
   # Verify installation
   node --version  # v18 or higher
   pnpm --version  # v8 or higher
   
   # Install pnpm if needed
   npm install -g pnpm
   ```

### LlamaCloud Credentials

You will need:
- **LLAMA_CLOUD_API_KEY**: Your LlamaCloud API key
- **LLAMA_CLOUD_PROJECT_ID**: Project ID in LlamaCloud

Get these credentials from [LlamaCloud Console](https://cloud.llamaindex.ai).

## Initial Configuration

### 1. Clone and Configure Project

```bash
cd path/to/requirements-architect

# Copy configuration file
cp .env.example .env
```

### 2. Configure Environment Variables

Edit the `.env` file:

```bash
# LlamaCloud credentials
LLAMA_CLOUD_API_KEY=llx-xxxxxxxxxxxxxxxxxxxxx
LLAMA_CLOUD_PROJECT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Environment (prod or staging)
LLAMA_CLOUD_ENV=prod

# UTF-8 Configuration (CRITICAL on Windows)
PYTHONIOENCODING=utf-8
PYTHONUTF8=1
```

### 3. Configure Extraction Schema

Edit `configs/config.json` to define your extraction schema:

```json
{
  "extract": {
    "json_schema": {
      "type": "object",
      "properties": {
        "field1": {"type": "string", "description": "Field 1 description"},
        "field2": {"type": "number", "description": "Field 2 description"}
      },
      "required": ["field1"]
    },
    "settings": {
      "extraction_mode": "PREMIUM",
      "use_reasoning": true,
      "cite_sources": true
    }
  }
}
```

## Local Deployment

### Quick Start

```bash
# Load environment variables (Windows PowerShell)
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^#].+?)=(.+)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
    }
}

# Start server
uvx llamactl serve
```

### Verification

1. Open your browser at `http://localhost:8000`
2. You should see the user interface
3. Check console logs for errors

### UI Development

If you need to modify the frontend:

```bash
cd ui

# Install dependencies
pnpm install

# Development (with hot reload)
pnpm run dev

# Build for production
pnpm run build
```

## Production Deployment

### Option 1: Dedicated Server

```bash
# 1. Install system dependencies
apt-get update
apt-get install -y python3.12 python3-pip

# 2. Configure environment variables
export LLAMA_CLOUD_API_KEY="your-key"
export LLAMA_CLOUD_PROJECT_ID="your-project-id"
export PYTHONIOENCODING=utf-8
export PYTHONUTF8=1

# 3. Start with supervisor or systemd
uvx llamactl serve --host 0.0.0.0 --port 8000
```

#### Systemd Service Example

Create `/etc/systemd/system/extraction-review.service`:

```ini
[Unit]
Description=Requirements Review Service
After=network.target

[Service]
Type=simple
User=your-user
WorkingDirectory=/path/to/requirements-architect
Environment="LLAMA_CLOUD_API_KEY=your-key"
Environment="LLAMA_CLOUD_PROJECT_ID=your-project-id"
Environment="PYTHONIOENCODING=utf-8"
Environment="PYTHONUTF8=1"
ExecStart=/home/your-user/.local/bin/uvx llamactl serve --host 0.0.0.0
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable extraction-review
sudo systemctl start extraction-review
sudo systemctl status extraction-review
```

### Option 2: Docker

Create a `Dockerfile`:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy project files
COPY . .

# Configure UTF-8
ENV PYTHONIOENCODING=utf-8
ENV PYTHONUTF8=1
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Expose port
EXPOSE 8000

# Start application
CMD ["uvx", "llamactl", "serve", "--host", "0.0.0.0"]
```

```bash
# Build and run
docker build -t extraction-review .
docker run -p 8000:8000 \
  -e LLAMA_CLOUD_API_KEY=your-key \
  -e LLAMA_CLOUD_PROJECT_ID=your-project-id \
  extraction-review
```

### Option 3: LlamaCloud Deployment

For deployment on LlamaCloud, see the [official documentation](https://developers.llamaindex.ai/python/llamaagents/deployment/).

## Common Troubleshooting

### Error: UnicodeDecodeError

**Symptom:**
```
UnicodeDecodeError: 'utf-8' codec can't decode byte 0xf3 in position X
```

**Solution:**
```bash
# Windows PowerShell
$env:PYTHONIOENCODING="utf-8"
$env:PYTHONUTF8="1"

# Linux/Mac
export PYTHONIOENCODING=utf-8
export PYTHONUTF8=1
```

Make sure these variables are in your `.env` file and loaded before running the application.

### Error: Port in Use

**Symptom:**
```
Error: Address already in use
```

**Windows Solution:**
```powershell
# Find process using port 8000
netstat -ano | findstr :8000

# Kill the process (replace PID with the found number)
taskkill /PID <PID> /F
```

**Linux/Mac Solution:**
```bash
# Find and kill process
lsof -ti:8000 | xargs kill -9
```

### Error: Invalid Credentials

**Symptom:**
```
Authentication failed
```

**Solution:**
1. Verify that `LLAMA_CLOUD_API_KEY` is valid
2. Verify that `LLAMA_CLOUD_PROJECT_ID` exists
3. Make sure variables are being loaded:
   ```bash
   echo $LLAMA_CLOUD_API_KEY  # Linux/Mac
   $env:LLAMA_CLOUD_API_KEY   # Windows
   ```

### Error: Module Not Found

**Symptom:**
```
ModuleNotFoundError: No module named 'llama_index'
```

**Solution:**
```bash
# Reinstall dependencies
uv pip install -e .
```

## Maintenance

### Dependency Updates

```bash
# Update Python packages
uv pip install --upgrade -r pyproject.toml

# Update UI packages
cd ui
pnpm update
```

### Monitoring

Implement monitoring for:
- **Logs**: Use Python `logging`, configure INFO or DEBUG level
- **Metrics**: Processing time, error rate
- **Alerts**: Extraction failures, API errors

### Backup

Configure regular backups of:
- `configs/config.json`: Schema configuration
- `.env`: Environment variables (without credentials in repository)
- Extracted data in LlamaCloud Agent Data collections

### Logs

Logs can be found at:
```bash
# View real-time logs
uvx llamactl serve --log-level DEBUG

# In production with systemd
sudo journalctl -u extraction-review -f
```

## Deployment Checklist

- [ ] Python 3.12+ installed
- [ ] uv installed
- [ ] Environment variables configured in `.env`
- [ ] `PYTHONIOENCODING=utf-8` and `PYTHONUTF8=1` configured (Windows)
- [ ] Valid LlamaCloud API key and Project ID
- [ ] Extraction schema defined in `configs/config.json`
- [ ] Port 8000 available (or alternative configured)
- [ ] UI build completed (`cd ui && pnpm run build`)
- [ ] Tests executed (`uv run hatch run test`)
- [ ] Monitoring service configured (production)
- [ ] Backups configured (production)

## Support and Resources

- [LlamaIndex Documentation](https://docs.llamaindex.ai/)
- [LlamaAgents Documentation](https://developers.llamaindex.ai/python/llamaagents/)
- [LlamaCloud Console](https://cloud.llamaindex.ai/)
- [GitHub Issues](https://github.com/run-llama/llama_index/issues)

## Contact

For additional support or project-specific questions, contact the development team.
