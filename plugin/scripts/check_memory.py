#!/usr/bin/env python3
"""Check that Chiron answers a recall, the same call Claude makes.

Unlike the hook, which stays silent when memory is down so prompts never
break, this fails loudly: exit code 1 and the reason.
"""
import sys

from chiron_mcp import CHIRON_MCP_URL, call_tool

try:
    result = call_tool("recall", {"query": "hello", "limit": 1}, timeout_seconds=10)
except Exception as error:
    print(f"Chiron memory is NOT working: {CHIRON_MCP_URL} gave {error}")
    sys.exit(1)
if result.get("isError"):
    print("Chiron memory is NOT working: recall returned an error:", result["content"][0]["text"])
    sys.exit(1)
cues = (result.get("structuredContent") or {}).get("cues") or []
print(f"Chiron memory is working ({'has memories' if cues else 'empty so far'}).")
