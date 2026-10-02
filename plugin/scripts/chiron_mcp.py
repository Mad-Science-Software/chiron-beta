"""Call a Chiron MCP tool over plain HTTP.

The server is stateless, so a single tools/call request works without an
initialize handshake.
"""
import json
import os
import urllib.request

CHIRON_MCP_URL = os.environ.get("CHIRON_MCP_URL", "http://localhost:8090/mcp")


def call_tool(tool_name, arguments, timeout_seconds=None):
    """Return the tools/call result object; raises on network or HTTP errors."""
    request = urllib.request.Request(
        CHIRON_MCP_URL,
        data=json.dumps({"jsonrpc": "2.0", "id": 1, "method": "tools/call",
                         "params": {"name": tool_name, "arguments": arguments}}).encode(),
        headers={"Content-Type": "application/json", "Accept": "application/json, text/event-stream",
                 "Mcp-Protocol-Version": "2025-11-25"},
    )
    return json.load(urllib.request.urlopen(request, timeout=timeout_seconds))["result"]
