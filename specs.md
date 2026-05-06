Prepare for scenarios like this. Where a use talks to an LLM, which does the toolcalls from MCP:

Tell me which grocery lists I have.

Add chocolate to my grocery list.

Remove choco from my grocery list.

There is no choco on your default list, but I do see "chocolate" on it. Do you want to remove that?


Everything can be passed in by name or by ID

## MCP Client Requirements & Transport Protocols

Leverage nginx for authorisation or https and reverse proxy where required.

Different LLM clients and agents connect to MCP servers using specific transport protocols (`stdio` or `sse`). Because the Paprika MCP server can run strictly locally (via `uv`) or as a network service (via Docker/Nginx HTTP/SSE), it is important to map out how to connect each supported client.

### 1. Claude Desktop
- **Transport**: `stdio` (native), `sse` (via bridge/proxy or native if supported).
- **Requirements**: By default, Claude Desktop spawns the server as a local child process using `stdio`. To connect to this server remotely via its SSE endpoint, you typically use a bridge like `@browserbasehq/mcp-sse-bridge` deployed via `npx` in the `claude_desktop_config.json`.

### 2. Home Assistant
- **Transport**: `sse`.
- **Requirements**: Home Assistant acts as a network client and requires a persistent HTTP/SSE connection. It can connect internally (`http://<ip>:8000/mcp/sse`) or externally using HTTPS. Supports Basic Authentication.

### 3. Google Antigravity
- **Transport**: `stdio` or `sse`.
- **Requirements**: Supports acting as an MCP client interacting with local commands or remote endpoints. Reaching a remote Dockerized setup would utilize the `sse` URL configuration.

### 4. Gemini CLI
- **Transport**: `stdio` or `sse`.
- **Requirements**: Command-line interfaces typically favor spawning local tools via `stdio`, but modern integrations also allow connecting to a remote context source utilizing `sse` and standard HTTP headers.

### 5. VSCode GitHub Copilot
- **Transport**: `stdio` and `sse`.
- **Requirements**: The GitHub Copilot Chat extension supports integrating MCP servers via the VS Code settings (e.g., `github.copilot.chat.mcpServers`). It supports both local `stdio` subprocesses and remote `sse` endpoints.

### 6. Claude.ai (Web)
- **Transport**: Secure `sse` (HTTPS).
- **Requirements**: Web-based cloud models cannot spawn local subprocesses. To supply context to Claude web, the MCP server must be exposed to the public internet securely (HTTPS via a reverse proxy like Nginx or Cloudflare Tunnels).

### 7. Gemini (Web)
- **Transport**: Secure `sse` (HTTPS).
- **Requirements**: Similar to Claude Web, supplying an external MCP server to Gemini Web requires a resolvable, public-facing HTTPS SSE endpoint that the Google cloud can reach securely.
