"""Call a Chiron MCP tool.

Talks to the native app over its socket (~/.chiron/chiron.sock) when it's
installed, otherwise to the Docker beta over HTTP (localhost:8090). The server
is stateless, so a single tools/call request works without an initialize
handshake.
"""
import http.client
import json
import os
import socket
import urllib.request

CHIRON_HOME = os.environ.get("CHIRON_HOME", os.path.join(os.path.expanduser("~"), ".chiron"))
SOCKET_PATH = os.path.join(CHIRON_HOME, "chiron.sock")
CHIRON_MCP_URL = os.environ.get("CHIRON_MCP_URL", "http://localhost:8090/mcp")
HEADERS = {"Content-Type": "application/json", "Accept": "application/json, text/event-stream",
           "Mcp-Protocol-Version": "2025-11-25"}


class _UnixHTTPConnection(http.client.HTTPConnection):
    def __init__(self, socket_path, timeout=None):
        super().__init__("localhost", timeout=timeout)
        self._socket_path = socket_path

    def connect(self):
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        if self.timeout is not None:
            self.sock.settimeout(self.timeout)
        self.sock.connect(self._socket_path)


def where():
    """Describe where calls go, for messages."""
    if "CHIRON_MCP_URL" not in os.environ and os.path.exists(SOCKET_PATH):
        return SOCKET_PATH
    return CHIRON_MCP_URL


def call_tool(tool_name, arguments, timeout_seconds=None):
    """Return the tools/call result object; raises on connection or HTTP errors."""
    body = json.dumps({"jsonrpc": "2.0", "id": 1, "method": "tools/call",
                       "params": {"name": tool_name, "arguments": arguments}}).encode()
    if "CHIRON_MCP_URL" not in os.environ and os.path.exists(SOCKET_PATH):
        connection = _UnixHTTPConnection(SOCKET_PATH, timeout=timeout_seconds)
        try:
            connection.request("POST", "/mcp", body=body, headers=HEADERS)
            response = connection.getresponse()
            if response.status != 200:
                raise RuntimeError(f"chiron answered {response.status}: {response.read()[:200]!r}")
            return json.load(response)["result"]
        finally:
            connection.close()
    request = urllib.request.Request(CHIRON_MCP_URL, data=body, headers=HEADERS)
    return json.load(urllib.request.urlopen(request, timeout=timeout_seconds))["result"]
