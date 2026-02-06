# Data Extraction and Ingestion

This is a LlamaAgents-based application for extracting structured data from documents. The system uses LlamaIndex and LlamaCloud to process files, extract structured information based on customizable schemas, and provide a review interface for validation and approval.

## About This Project

### What problem does this agent solve?

This application solves the challenge of extracting structured data from unstructured documents at scale. It automates the process of:
- Uploading and processing documents of various formats
- Extracting specific fields based on custom JSON schemas
- Providing a review interface for human validation
- Storing validated extractions for downstream use

The system is particularly useful for requirements analysis, technical specifications extraction, and any scenario where structured data needs to be extracted from documents while maintaining human oversight.

### How it was built

This project is built using:
- **LlamaIndex Workflows**: For orchestrating the extraction pipeline
- **LlamaCloud**: For document processing and extraction APIs
- **LlamaAgents (llamactl)**: For deployment and service orchestration
- **React + TypeScript**: For the review UI
- **Pydantic**: For data validation and schema management

The development process involved:
1. Designing flexible workflows for file processing and metadata management
2. Implementing a dynamic UI that adapts to custom extraction schemas
3. Integrating with LlamaCloud's extraction and agent data APIs
4. Creating a seamless review and approval workflow

For a detailed project overview, see [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md).

## Quick Start

**First time using this project?** Check [QUICKSTART.md](QUICKSTART.md) for a 5-minute setup guide.

To run the application, install [`uv`](https://docs.astral.sh/uv/) and run `uvx llamactl serve`.

See the [LlamaAgents (llamactl) getting started guide](https://developers.llamaindex.ai/python/llamaagents/llamactl/getting-started/) for context on local development and deployment.

## Setup and Installation

### Prerequisites

- Python 3.12 or higher
- [uv](https://docs.astral.sh/uv/) package manager
- Node.js and pnpm (for UI development)
- LlamaCloud API key and Project ID

### Environment Configuration

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your credentials:
   ```bash
   LLAMA_CLOUD_API_KEY=your-api-key-here
   LLAMA_CLOUD_PROJECT_ID=your-project-id-here
   LLAMA_CLOUD_ENV=prod
   ```

3. **Important for Windows users**: Keep these encoding settings in your `.env`:
   ```bash
   PYTHONIOENCODING=utf-8
   PYTHONUTF8=1
   ```

### Running Locally

**Option 1: Use startup script (Recommended)**

```bash
# Windows (PowerShell)
.\start.ps1

# Linux/Mac
chmod +x start.sh
./start.sh
```

The scripts automatically:
- Load environment variables from `.env`
- Configure UTF-8 correctly
- Verify credentials
- Start the server

**Option 2: Manual start**

```bash
# Load environment variables and configure UTF-8

# Windows (PowerShell)
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^#].+?)=(.+)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
    }
}
$env:PYTHONIOENCODING="utf-8"
$env:PYTHONUTF8="1"

# Linux/Mac
set -a && source .env && set +a
export PYTHONIOENCODING=utf-8
export PYTHONUTF8=1

# Start server
uvx llamactl serve

# The application will be available at http://localhost:8000
```

For detailed production deployment information, see [DEPLOYMENT.md](DEPLOYMENT.md).

## Deployment

### Option 1: Local Development Server

```bash
uvx llamactl serve
```

### Option 2: Production Deployment

For production deployment, refer to the [LlamaAgents deployment documentation](https://developers.llamaindex.ai/python/llamaagents/deployment/).

Key considerations:
- Ensure all environment variables are properly set
- Configure appropriate API rate limits
- Set up monitoring and logging
- Implement proper error handling and alerting

### Configuration Files

- **`configs/config.json`**: Contains extraction schemas and settings
- **`.env`**: Environment variables for API keys and configuration
- **`pyproject.toml`**: Python dependencies and project metadata
- **`ui/package.json`**: UI dependencies and scripts

## Troubleshooting

### UnicodeDecodeError on Windows

**Error message:**
```
UnicodeDecodeError: 'utf-8' codec can't decode byte 0xf3 in position X: invalid continuation byte
```

**Cause:** This error occurs on Windows systems when the console encoding doesn't match UTF-8, particularly on systems configured for Spanish or other non-English locales.

**Solution:**

1. **Set environment variables** (recommended):
   Add these to your `.env` file or system environment:
   ```bash
   PYTHONIOENCODING=utf-8
   PYTHONUTF8=1
   ```

2. **Alternative: Set in PowerShell before running**:
   ```powershell
   $env:PYTHONIOENCODING="utf-8"
   $env:PYTHONUTF8="1"
   uvx llamactl serve
   ```

3. **Permanent Windows solution**:
   Add these as system environment variables:
   - Open "System Properties" → "Environment Variables"
   - Add `PYTHONIOENCODING` = `utf-8`
   - Add `PYTHONUTF8` = `1`

### Other Common Issues

**Port already in use:**
```bash
# Kill the process using port 8000 (default)
# Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux/Mac:
lsof -ti:8000 | xargs kill -9
```

**Missing API credentials:**
Ensure your `.env` file contains valid `LLAMA_CLOUD_API_KEY` and `LLAMA_CLOUD_PROJECT_ID`.

**UI not loading:**
Check that the UI build completed successfully:
```bash
cd ui
pnpm install
pnpm run build
```


## Simple customizations

For some basic customizations, you can modify `src/extraction_review/config.py`

- **`EXTRACTION_AGENT_NAME`**: Logical name for your Extraction Agent. When `USE_REMOTE_EXTRACTION_SCHEMA` is `False`, this name is used to upsert the agent with your local schema; when `True`, it is used to fetch an existing agent.
- **`EXTRACTED_DATA_COLLECTION`**: The Agent Data collection name used to store extractions (namespaced by agent name and environment).
- **`ExtractionSchema`**: When using a local schema, edit this Pydantic model to match the fields you want extracted. Prefer optional types where possible to allow for partial extractions. Note that the extraction process requires all values! so you must explicitly set values to be optional if they are not required. (pydantic default factories will not work, as pydantic only uses default values for missing fields).

The UI fetches the JSON Schema and collection name from the backend metadata workflow at runtime, and dynamically
generates an editing UI based on the schema. If you customize this application to have a different extraction schema from
the presentation schema rendered in the UI, for example if you customize the extraction process to add additional fields or otherwise
transforma it, then you must return the presentation schema from the metadata workflow.

## Complex customizations

For more complex customizations, you can edit the rest of the application. For example, you could
- Modify the existing file processing workflow to provide additional context for the extraction process
- Take further action based on the extracted data.
- Add additional workflows to submit data upon approval.

## Linting and type checking

Python and javascript packages contain helpful scripts to lint, format, and type check the code.

To check and fix python code:

```bash
uv run hatch run lint
uv run hatch run typecheck
uv run hatch run test
# run all at once
uv run hatch run all-fix
```

To check and fix javascript code, within the `ui` directory:

```bash
pnpm run lint
pnpm run typecheck
pnpm run test
# run all at once
pnpm run all-fix
```