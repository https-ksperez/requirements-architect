# Changelog

All notable improvements and changes to this project will be documented in this file.

## [Unreleased] - 2026-02-05

### Fixed

#### 🐛 UnicodeDecodeError on Windows
- **Problem**: Error `UnicodeDecodeError: 'utf-8' codec can't decode byte 0xf3 in position 168` when running `uvx llamactl serve` on Windows systems configured in Spanish or other languages.
- **Root cause**: LlamaAgents/Python attempted to decode process output using UTF-8, but Windows used cp1252/latin-1 encoding by default.
- **Implemented solution**:
  - Configuration of environment variables `PYTHONIOENCODING=utf-8` and `PYTHONUTF8=1`
  - Automated startup scripts that configure the environment correctly
  - Detailed documentation of problem and solutions

### Added

#### 📄 Complete Documentation

1. **README.md** (updated)
   - "About This Project" section with problem description
   - Build process and technology stack
   - Setup and installation guide
   - Complete troubleshooting section
   - Links to additional documentation

2. **QUICKSTART.md** (new)
   - 5-minute startup guide
   - Basic configuration steps
   - Quick troubleshooting for common issues
   - First steps with the application

3. **DEPLOYMENT.md** (new)
   - Complete deployment guide
   - Detailed prerequisites
   - Step-by-step configuration
   - Deployment options (dedicated server, Docker, systemd)
   - Advanced troubleshooting
   - Deployment checklist
   - Maintenance strategies

4. **PROJECT_SUMMARY.md** (new)
   - Detailed description of the problem the agent solves
   - Technology stack and architecture
   - Complete development process
   - Technical challenges and solutions
   - Success metrics
   - Next steps and planned improvements

#### 🛠️ Configuration Files

5. **.env.example** (new)
   - Template for environment variables
   - Includes UTF-8 configuration for Windows
   - Explanatory comments for each variable
   - Ready to copy and configure

#### 🚀 Automated Startup Scripts

6. **start.ps1** (new - Windows PowerShell)
   - Automatic loading of variables from `.env`
   - UTF-8 configuration (encoding + code page)
   - Credential verification
   - Informative messages with colors
   - Error handling with suggestions
   
7. **start.sh** (new - Linux/Mac Bash)
   - Unix equivalent of PowerShell script
   - Loading variables from `.env`
   - Locale and encoding configuration
   - Prerequisite verification
   - Error handling with exit codes

### Documentation Structure

```
requirements-architect/
├── README.md              # Main documentation
├── QUICKSTART.md          # Quick start guide (5 min)
├── DEPLOYMENT.md          # Complete deployment guide
├── PROJECT_SUMMARY.md     # Technical project summary
├── CHANGELOG.md           # This file
├── .env.example           # Configuration template
├── start.ps1              # Startup script for Windows
├── start.sh               # Startup script for Linux/Mac
└── configs/
    └── config.json        # Schema configuration
```

### Benefits

#### For Users
- ✅ Clear solution to Unicode error on Windows
- ✅ Simplified startup with automated scripts
- ✅ Complete documentation in English
- ✅ Multiple documentation levels (quick start → deployment)

#### For Development
- ✅ Improved onboarding process
- ✅ Documented troubleshooting
- ✅ Reusable scripts
- ✅ Configuration template

#### For Presentation/Portfolio
- ✅ Clear description of problem solved
- ✅ Documentation of build process
- ✅ Documented technology stack
- ✅ Explained challenges and solutions

## Technical Notes

### UnicodeDecodeError - Technical Analysis

**Original stack trace:**
```
File "llama_deploy/appserver/process_utils.py", line 201, in _stream_source
    for line in iter(source.readline, ""):
UnicodeDecodeError: 'utf-8' codec can't decode byte 0xf3 in position 168
```

**Analysis:**
- Byte `0xf3` is 'ó' in latin-1/cp1252 encoding
- Windows uses cp1252 on systems configured for Spanish
- LlamaAgents reads subprocess output without specifying encoding
- By default Python uses UTF-8, causing conflict

**Relevant environment variables:**
- `PYTHONIOENCODING`: Forces encoding for stdin/stdout/stderr
- `PYTHONUTF8`: Activates UTF-8 mode on Windows (PEP 540)
- `LANG` / `LC_ALL`: Locale configuration (Unix)

### Best Practices Implemented

1. **Centralized configuration**: All variables in `.env`
2. **Idempotent scripts**: Can be run multiple times
3. **Early validation**: Verify credentials before starting
4. **Clear feedback**: Informative messages with color codes
5. **Graduated documentation**: Quick start → README → Deployment

## Referencias

- [PEP 540 – UTF-8 Mode](https://peps.python.org/pep-0540/)
- [Python Unicode HOWTO](https://docs.python.org/3/howto/unicode.html)
- [LlamaAgents Documentation](https://developers.llamaindex.ai/python/llamaagents/)

---

**Change type**: `Fixed` (bug fixes), `Added` (new features)  
**Impact**: High - Resolves blocker for Windows users  
**Testing**: Verified on Windows 11 with PowerShell 5.1
