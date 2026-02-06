# Data Extraction and Ingestion - Project Summary

## What problem does this agent solve?

### Context

In many organizations, there is a large volume of unstructured documents (PDFs, Word documents, images, etc.) containing valuable information that is difficult to process automatically. Manual data extraction from these documents is:

- **Slow**: Requires human review document by document
- **Error-prone**: Manual transcription introduces inconsistencies
- **Not scalable**: Document volume grows faster than human capacity
- **Expensive**: Consumes valuable time from qualified personnel

### Solution

This agent automates the process of **extracting structured data from unstructured documents**, providing:

1. **Automated Extraction**: Uses AI models (LlamaIndex + LlamaCloud) to extract specific information based on customizable schemas
2. **Human Validation**: Review interface for experts to validate and correct extractions
3. **Flexible Schemas**: Configuration via JSON Schema to adapt to any document type
4. **Organized Storage**: Validated data is saved in structured collections ready for downstream use

### Use Cases

- **Technical Requirements Analysis**: Extraction of specifications from engineering documents
- **Contract Processing**: Identification of clauses, dates, amounts
- **Document Management**: Classification and metadata extraction
- **Audits**: Systematic collection of information from regulatory documents
- **Research**: Data extraction from academic papers or reports

## How was it built?

### Technology Stack

#### Backend
- **LlamaIndex Workflows**: Framework for orchestrating complex AI workflows
- **LlamaCloud**: API for document processing and AI extraction
- **Pydantic**: Data validation and schema definition
- **Python 3.12+**: Project base language
- **httpx**: Asynchronous HTTP client for file downloads
- **jsonref**: JSON Schema reference resolution

#### Frontend
- **React 18**: Framework for user interface
- **TypeScript**: Type safety in the frontend
- **Vite**: Modern and fast build tool
- **Tailwind CSS**: Utility-first styles
- **shadcn/ui**: Accessible and customizable UI components

#### Deployment
- **LlamaAgents (llamactl)**: Agent orchestration and deployment
- **uv**: Ultra-fast Python package manager
- **pnpm**: Efficient JavaScript package manager

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Cliente (Browser)                     │
│                    React + TypeScript                    │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP/REST
                     ▼
┌─────────────────────────────────────────────────────────┐
│              LlamaAgents Server (llamactl)              │
│                                                          │
│  ┌────────────────────┐      ┌────────────────────┐   │
│  │ MetadataWorkflow   │      │ ProcessFileWorkflow│   │
│  │ - Get Schema       │      │ - Download File    │   │
│  │ - Get Config       │      │ - Extract Data     │   │
│  └────────────────────┘      │ - Save to DB       │   │
│                               └────────────────────┘   │
└────────────────┬───────────────────┬────────────────────┘
                 │                   │
                 ▼                   ▼
      ┌──────────────────┐  ┌──────────────────┐
      │  LlamaCloud API  │  │  Agent Data API  │
      │  - File Storage  │  │  - Collections   │
      │  - Extraction    │  │  - CRUD Ops      │
      └──────────────────┘  └──────────────────┘
```

### Componentes Principales

#### 1. **MetadataWorkflow** ([metadata_workflow.py](src/extraction_review/metadata_workflow.py))
- Proporciona el schema JSON al frontend
- Configura el nombre de la colección de datos
- Permite que la UI se adapte dinámicamente al schema

#### 2. **ProcessFileWorkflow** ([process_file.py](src/extraction_review/process_file.py))
- **Paso 1**: Descarga el archivo desde LlamaCloud
- **Paso 2**: Inicia el job de extracción con el schema configurado
- **Paso 3**: Espera y obtiene los resultados
- **Paso 4**: Guarda los datos extraídos en Agent Data
- **Paso 5**: Reporta progreso mediante eventos

#### 3. **Frontend Dinámico** ([ui/src](ui/src))
- **MetadataProvider**: Obtiene schema y configuración
- **HomePage**: Lista de archivos procesados
- **ItemPage**: Editor dinámico basado en schema
- Automatically generates forms from JSON Schema

### Development Process

#### Phase 1: Design and Planning
1. **Requirements Analysis**: Identify need for flexible extraction
2. **Stack Selection**: Evaluate LlamaIndex vs other options
3. **Architecture Design**: Separate workflows for metadata and processing

#### Phase 2: Backend Implementation
1. **Initial setup**: Configure pyproject.toml with dependencies
2. **Workflows**: Implement extraction and metadata logic
3. **Configuration**: Flexible JSON-based system for schemas
4. **Testing**: Unit and integration tests

#### Phase 3: Frontend Implementation
1. **UI Setup**: Configure Vite + React + TypeScript
2. **API Client**: Wrapper over LlamaCloud SDK
3. **Dynamic Components**: Form generation from schema
4. **State**: Context API for global state management

#### Phase 4: Integration and Testing
1. **E2E Testing**: Tests with Playwright
2. **Type Checking**: TypeScript + ty for Python
3. **Linting**: Ruff for Python, ESLint for TypeScript
4. **CI/CD**: Automated scripts with hatch

#### Phase 5: Deployment and Documentation
1. **Startup scripts**: Automation for Windows/Linux/Mac
2. **Documentation**: README, DEPLOYMENT, troubleshooting
3. **Configuration**: Templates (.env.example)
4. **Encoding solution**: Fix for Windows UTF-8

### Technical Challenges and Solutions

#### 1. **UnicodeDecodeError on Windows**
**Problem**: Windows uses cp1252 encoding by default, causing errors when reading process outputs.

**Solution**: 
- Configure `PYTHONIOENCODING=utf-8` and `PYTHONUTF8=1`
- Startup scripts that configure automatically
- Clear documentation in troubleshooting

#### 2. **Dynamic Schema in UI**
**Problem**: Extraction schema must be configurable without changing code.

**Solution**:
- JSON Schema as source of truth
- Dynamic React form generation
- MetadataWorkflow to synchronize frontend/backend

#### 3. **Asynchronous State Management**
**Problem**: Workflows can take minutes, we need real-time feedback.

**Solution**:
- Event system in workflows
- Progress streaming to frontend
- Context API for global state management

#### 4. **Data Validation**
**Problem**: Extracted data may be incomplete or incorrect.

**Solution**:
- Pydantic validation before saving
- Review UI for human correction
- Optional fields in schema to allow partials

## Success Metrics

### Functionality
- ✅ Automatic extraction from multiple formats (PDF, DOCX, images)
- ✅ Customizable schema via JSON configuration
- ✅ Adaptive UI generated from schema
- ✅ Persistent storage in LlamaCloud
- ✅ Real-time feedback during processing

### Code Quality
- ✅ Type checking (Python: ty, TypeScript: tsc)
- ✅ Linting (Ruff, ESLint)
- ✅ Automated testing (pytest, vitest, playwright)
- ✅ Complete documentation

### Developer Experience
- ✅ Automated startup scripts
- ✅ Configuration via JSON files
- ✅ Hot reload in development
- ✅ Documented troubleshooting

## Next Steps

### Planned Improvements
1. **Batch Processing**: Process multiple files in parallel
2. **Webhooks**: Notifications when extraction completes
3. **Analytics Dashboard**: Accuracy and volume metrics
4. **Custom Validators**: Custom validations per field
5. **Export Options**: Export to CSV, Excel, JSON

### Scalability
- Queue system for high-volume handling
- Caching of extraction results
- Prompt optimization to reduce costs
- Rate limiting and retry logic

## Conclusions

This project demonstrates:
- **Effective integration** of multiple technologies (LlamaIndex, React, LlamaCloud)
- **Flexible design** that adapts to different use cases through configuration
- **Attention to detail** in UX, documentation, and error handling
- **Practical solution** to a real document automation problem

The result is a production-ready tool that significantly reduces the time and effort required to extract structured data from unstructured documents, while maintaining the human oversight necessary to ensure quality.

## References

- [LlamaIndex Documentation](https://docs.llamaindex.ai/)
- [LlamaAgents Documentation](https://developers.llamaindex.ai/python/llamaagents/)
- [LlamaCloud API](https://cloud.llamaindex.ai/api-docs)
- [JSON Schema](https://json-schema.org/)
- [Pydantic](https://docs.pydantic.dev/)
- [React Documentation](https://react.dev/)

---

**Author**: [Your Name]  
**Date**: February 2026  
**Version**: 0.1.0
