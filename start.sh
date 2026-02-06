#!/bin/bash
# Linux/Mac startup script
# This script configures necessary environment variables and starts the server

echo "=================================="
echo "Requirements Architect (User Stories & Use Cases)"
echo "=================================="
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "ERROR: .env file not found"
    echo "Please copy .env.example to .env and configure your credentials"
    echo ""
    echo "Run: cp .env.example .env"
    exit 1
fi

echo "Loading environment variables from .env..."

# Load environment variables from .env
set -a
source .env
set +a

echo "  ✓ Environment variables loaded"

# Configure UTF-8 encoding
echo ""
echo "Configuring UTF-8 encoding..."
export PYTHONIOENCODING=utf-8
export PYTHONUTF8=1
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "  ✓ PYTHONIOENCODING=utf-8"
echo "  ✓ PYTHONUTF8=1"
echo "  ✓ LANG=en_US.UTF-8"

# Verify credentials
echo ""
if [ -z "$LLAMA_CLOUD_API_KEY" ]; then
    echo "WARNING: LLAMA_CLOUD_API_KEY is not configured"
fi
if [ -z "$LLAMA_CLOUD_PROJECT_ID" ]; then
    echo "WARNING: LLAMA_CLOUD_PROJECT_ID is not configured"
fi

# Start the server
echo ""
echo "Starting LlamaAgents server..."
echo "The application will be available at: http://localhost:8000"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

uvx llamactl serve

# Capture exit code
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo ""
    echo "ERROR: Could not start the server (exit code: $EXIT_CODE)"
    echo ""
    echo "Possible solutions:"
    echo "  1. Verify that 'uv' is installed: uv --version"
    echo "  2. Verify that port 8000 is available"
    echo "  3. Check your credentials in .env"
    echo ""
    echo "For more help, see DEPLOYMENT.md"
    exit $EXIT_CODE
fi
