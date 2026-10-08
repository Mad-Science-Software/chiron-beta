"""Call a Chiron MCP tool.

With the native app installed, it goes through the app's own relay,
`chiron mcp` (Python on Windows can't open the app's Unix socket, and one
route keeps every platform alike); otherwise it talks to the Docker beta over
HTTP (localhost:8090). The server is stateless, so a single tools/call request
works without an initialize handshake.
"""
import json
import os
import subprocess
import sys
import urllib.request

CHIRON_HOME = os.environ.get("CHIRON_HOME", os.path.join(os.path.expanduser("~"), ".chiron"))
APP_PROGRAM = os.path.join(CHIRON_HOME, "bin", "chiron.exe" if sys.platform == "win32" else "chiron")
CHIRON_MCP_URL = os.environ.get("CHIRON_MCP_URL", "http://localhost:8090/mcp")
HEADERS = {"Content-Type": "application/json", "Accept": "application/json, text/event-stream",
           "Mcp-Protocol-Version": "2025-11-25"}


def _uses_app():
    return "CHIRON_MCP_URL" not in os.environ and os.path.exists(APP_PROGRAM)


def where():
    """Describe where calls go, for messages."""
    return f"{APP_PROGRAM} mcp" if _uses_app() else CHIRON_MCP_URL


def call_tool(tool_name, arguments, timeout_seconds=None):
    """Return the tools/call result object; raises on connection or HTTP errors."""
    request = {"jsonrpc": "2.0", "id": 1, "method": "tools/call",
               "params": {"name": tool_name, "arguments": arguments}}
    if _uses_app():
        completed = subprocess.run([APP_PROGRAM, "mcp"], input=json.dumps(request) + "\n",
                                   capture_output=True, text=True, encoding="utf-8",
                                   timeout=timeout_seconds, check=False)
        lines = [line for line in completed.stdout.splitlines() if line.strip()]
        if not lines:
            raise RuntimeError(f"chiron mcp gave no answer: {completed.stderr.strip()[:300]}")
        reply = json.loads(lines[-1])
        if "error" in reply:
            raise RuntimeError(reply["error"].get("message", reply["error"]))
        return reply["result"]
    body = json.dumps(request).encode()
    http_request = urllib.request.Request(CHIRON_MCP_URL, data=body, headers=HEADERS)
    return json.load(urllib.request.urlopen(http_request, timeout=timeout_seconds))["result"]
