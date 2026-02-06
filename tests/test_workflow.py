"""
Tests for the BRD Technical Specification Extractor workflow.
"""

import json
import warnings
from pathlib import Path

import pytest
from extraction_review.clients import fake
from extraction_review.config import EXTRACTED_DATA_COLLECTION
from extraction_review.metadata_workflow import MetadataResponse
from extraction_review.metadata_workflow import workflow as metadata_workflow
from extraction_review.process_file import FileEvent
from extraction_review.process_file import workflow as process_file_workflow
from workflows.events import StartEvent


def get_extraction_schema() -> dict:
    """Load the extraction schema from the unified config file."""
    config_path = Path(__file__).parent.parent / "configs" / "config.json"
    config = json.loads(config_path.read_text())
    return config["extract"]["json_schema"]


@pytest.mark.asyncio
async def test_process_file_workflow(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("LLAMA_CLOUD_API_KEY", "fake-api-key")
    if fake is not None:
        file_id = fake.files.preload(path="tests/files/test.pdf")
    else:
        warnings.warn(
            "Skipping test because it cannot be mocked. Set `FAKE_LLAMA_CLOUD=true` in your environment to enable this test..."
        )
        return
    result = await process_file_workflow.run(start_event=FileEvent(file_id=file_id))
    assert result is not None
    assert isinstance(result, str)
    assert len(result) == 7


@pytest.mark.asyncio
async def test_metadata_workflow() -> None:
    result = await metadata_workflow.run(start_event=StartEvent())
    assert isinstance(result, MetadataResponse)
    assert result.extracted_data_collection == EXTRACTED_DATA_COLLECTION
    assert result.json_schema == get_extraction_schema()


@pytest.mark.asyncio
async def test_extraction_schema_has_required_fields() -> None:
    """Verify the BRD extraction schema contains all required feature fields."""
    schema = get_extraction_schema()
    assert schema["type"] == "object"
    assert "features" in schema["properties"]
    feature_schema = schema["properties"]["features"]["items"]
    required_feature_fields = ["feature_id", "user_story", "priority", "acceptance_criteria", "dependencies", "technical_risks"]
    for field in required_feature_fields:
        assert field in feature_schema["properties"], f"Missing field: {field}"
