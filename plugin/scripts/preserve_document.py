#!/usr/bin/env python3
"""Preserve one agent-ingestion document in Chiron through the MCP preserve tool.

Usage: preserve_document.py <document.json> <cues.json>

cues.json is a JSON list of {"sentence", "authors", "observed_at"}. The
record_body, source, and external_id come from document.json, so the agent only
writes cues. A document that's already stored counts as done.
"""
import json
import sys

from chiron_mcp import call_tool

document_path, cues_path = sys.argv[1], sys.argv[2]
document = json.load(open(document_path))
cues = json.load(open(cues_path))
arguments = {
    "body": document["record_body"],
    "source": document["source"],
    "external_id": document["external_id"],
    "cues": cues,
}
result = call_tool("preserve", arguments)
text = result["content"][0]["text"] if result.get("content") else ""
if result.get("isError"):
    if "already stored" in text:
        print("ALREADY STORED", document["external_id"])
        sys.exit(0)
    print("ERROR", document["external_id"], text)
    sys.exit(1)
print("PRESERVED", document["external_id"], json.dumps(result.get("structuredContent")))
