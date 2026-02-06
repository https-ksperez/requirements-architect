# Quick Start Guide

## Setup in 5 Minutes

### 1. Prerequisites

Make sure you have installed:
- **Python 3.12+**: `python --version`
- **uv**: [Installation instructions](https://docs.astral.sh/uv/)

### 2. Get Credentials

1. Create an account on [LlamaCloud](https://cloud.llamaindex.ai/)
2. Create a new project
3. Get your **API Key** and **Project ID**

### 3. Configure the Project

```bash
# 1. Navigate to project directory
cd requirements-architect

# 2. Copy the configuration file
cp .env.example .env

# 3. Edit .env with your credentials
# Windows: notepad .env
# Linux/Mac: nano .env
```

In the `.env` file, configure:
```env
LLAMA_CLOUD_API_KEY=llx-your-api-key-here
LLAMA_CLOUD_PROJECT_ID=your-project-id-here
LLAMA_CLOUD_ENV=prod
PYTHONIOENCODING=utf-8
PYTHONUTF8=1
```

### 4. Start the Application

**Windows (PowerShell):**
```powershell
.\start.ps1
```

**Linux/Mac:**
```bash
chmod +x start.sh
./start.sh
```

### 5. Access the Application

Open your browser at: **http://localhost:8000**

Done! You can now start processing documents.

---

## First Use

### Upload a Document

1. From the interface, upload a PDF or document file
2. The system automatically:
   - Downloads the file
   - Extracts data according to the configured schema
   - Shows results for review

### Review Extractions

1. Click on a processed document
2. Review the extracted fields
3. Edit any field if necessary
4. Save changes

### Customize the Schema

Edit `configs/config.json` to change what data is extracted:

```json
{
  "extract": {
    "json_schema": {
      "type": "object",
      "properties": {
        "title": {
          "type": "string",
          "description": "Document title"
        },
        "date": {
          "type": "string",
          "description": "Document date in YYYY-MM-DD format"
        },
        "amount": {
          "type": "number",
          "description": "Total amount in the document"
        }
      },
      "required": ["title"]
    },
    "settings": {
      "extraction_mode": "PREMIUM",
      "use_reasoning": true,
      "cite_sources": true
    }
  }
}
```

Restart the server after changing the schema.

---

## Useful Commands

### Stop the Server
Press `Ctrl + C` in the terminal

### View Logs
Logs appear in the same terminal where you started the server

### Clear Cache
```bash
# Windows
Remove-Item -Recurse -Force __pycache__, .pytest_cache

# Linux/Mac
find . -type d -name "__pycache__" -exec rm -rf {} +
```

### Update Dependencies
```bash
uv pip install --upgrade -e .
```

---

## Quick Troubleshooting

### ❌ "UnicodeDecodeError"
**Solution**: Make sure `.env` contains:
```env
PYTHONIOENCODING=utf-8
PYTHONUTF8=1
```
Use the `start.ps1` or `start.sh` script which configures this automatically.

### ❌ "Port 8000 already in use"
**Windows Solution**:
```powershell
netstat -ano | findstr :8000
taskkill /PID <numero_pid> /F
```

**Linux/Mac Solution**:
```bash
lsof -ti:8000 | xargs kill -9
```

### ❌ "Authentication failed"
**Solution**: Verify that your API key is valid:
```bash
# Windows
$env:LLAMA_CLOUD_API_KEY

# Linux/Mac
echo $LLAMA_CLOUD_API_KEY
```

### ❌ "Module not found"
**Solution**:
```bash
uv pip install -e .
```

---

## Next Steps

- 📖 Read [README.md](README.md) to understand full capabilities
- 🚀 Check [DEPLOYMENT.md](DEPLOYMENT.md) for production deployment
- 📊 Review [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) for technical details

---

## Support

If you encounter issues:
1. Check the [Troubleshooting](README.md#troubleshooting) section in the README
2. Consult [DEPLOYMENT.md](DEPLOYMENT.md) for advanced configurations
3. Verify server logs for specific error messages

---

**Happy data extraction! 🎉**
