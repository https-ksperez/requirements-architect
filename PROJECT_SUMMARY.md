# Requirements Architect (User Stories & Use Cases) - Project Summary

## What problem does this agent solve?

### Context

In many teams, requirements are captured in unstructured documents (PDFs, Word docs, meeting notes, emails, images, etc.). Turning those raw requirements into *usable engineering artifacts*—especially **user stories** and **use cases**—is often harder than writing the code itself.

Even strong developers can struggle with:

- **Identifying the right stories**: Separating features, constraints, and non-goals
- **Writing consistent story formats**: Roles, goals, and value vary by author
- **Deriving use cases and flows**: Actors, preconditions, main/alternate flows, exceptions
- **Keeping traceability**: Linking extracted items back to the original source

When done manually, this work is:

- **Slow**: Requires human review document by document
- **Inconsistent**: Different engineers produce different outputs from the same input
- **Hard to scale**: Document volume grows faster than the team’s analysis capacity
- **Costly**: Consumes time from engineers and product stakeholders

### Solution

This agent helps teams move from raw requirement sources to structured, reviewable outputs by automating **requirements extraction and structuring**. It provides:

1. **Automated Structuring**: Uses LlamaIndex Workflows + LlamaCloud extraction to map unstructured text into a structured schema (e.g., user stories, use cases, acceptance criteria, metadata)
2. **Human-in-the-loop Review**: A UI where engineers can review, edit, and approve the generated artifacts
3. **Schema-driven Outputs**: JSON Schema controls *what* is extracted so teams can tailor it (stories vs. use cases vs. technical constraints)
4. **Organized Storage**: Approved results are saved as structured records, ready for backlog grooming, export, or downstream tooling

### Use Cases

- **Requirements → Backlog Seed**: Generate first-pass user stories and acceptance criteria from requirement documents
- **Use Case Discovery**: Identify actors, flows, and exceptions from narrative specs
- **Engineering Onboarding**: Help junior engineers learn how to translate requirements into structured stories
- **Consistency & Standardization**: Enforce a shared story/use-case format via schemas
- **Traceable Reviews**: Keep a reviewable audit trail of what was extracted and how it was corrected

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
- **React 19**: Framework for user interface
- **TypeScript**: Type safety in the frontend
- **Vite**: Modern and fast build tool
- **Tailwind CSS**: Utility-first styles
- **Radix UI Themes**: UI primitives and theming
- **shadcn/ui**: Component scaffolding and conventions
- **@llamaindex/ui**: LlamaIndex UI components used by the review experience

#### Deployment
- **LlamaAgents (llamactl)**: Agent orchestration and deployment
- **uv**: Ultra-fast Python package manager
- **pnpm**: Efficient JavaScript package manager

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      Client (Browser)                    │
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

### Core Components

#### 1. **MetadataWorkflow** ([metadata_workflow.py](src/extraction_review/metadata_workflow.py))
- Provides the JSON Schema to the frontend
- Supplies configuration like collection names
- Enables the UI to adapt dynamically to the active schema

#### 2. **ProcessFileWorkflow** ([process_file.py](src/extraction_review/process_file.py))
- **Step 1**: Download the file from LlamaCloud
- **Step 2**: Start an extraction job using the configured schema
- **Step 3**: Wait for completion and retrieve results
- **Step 4**: Persist extracted records into Agent Data
- **Step 5**: Stream progress via workflow events

#### 3. **Schema-driven Review UI** ([ui/src](ui/src))
- **MetadataProvider**: Fetches schema and configuration
- **HomePage**: Lists processed items/files
- **ItemPage**: Schema-driven editor for review and correction
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
3. **Linting/Formatting**: Ruff (Python) + Prettier (UI) + TypeScript checks via `tsc`
4. **Automation**: Hatch scripts for common checks (format/lint/test)

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
- ✅ Linting/formatting (Ruff, Prettier)
- ✅ Automated testing (pytest, pytest-playwright)
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
- **Flexible design** that adapts to different requirement schemas through configuration
- **Attention to detail** in UX, documentation, and error handling
- **Practical workflow** for turning raw requirements into reviewable engineering artifacts

The result is a tool that reduces the time and friction of identifying user stories and use cases from unstructured requirement sources, while keeping human oversight as the final quality gate.

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
