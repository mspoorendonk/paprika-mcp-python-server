#!/usr/bin/env bash
# add-mcp-client.sh — provision a new Basic-Auth user for the MCP endpoint
#
# Usage:
#   scripts/add-mcp-client.sh <tool> [machine]
#
# Examples:
#   scripts/add-mcp-client.sh claude-code laptop
#   scripts/add-mcp-client.sh claude-web        # web clients have no machine
#
# Recognised tools (used to print copy-pasteable connection snippets):
#   claude-code | claude-desktop | gemini-cli | vscode-copilot
#   antigravity | homeassistant | claude-web   | gemini-web
#
# Env vars:
#   HTPASSWD_FILE  default: /opt/stack/nginx/.htpasswd_mcp
#   MCP_URL        default: https://<your-domain>/paprika/mcp
#                  (set this to your real URL to get ready-to-paste snippets)
#
# Generated credential and connection snippet are written to:
#   tmp/credentials/<user>.txt        (gitignored: tmp/ is in .gitignore)

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <tool> [machine]" >&2
  exit 2
fi

tool="$1"
machine="${2:-}"

if [[ -n "$machine" ]]; then
  user="${tool}-${machine}"
else
  user="$tool"
fi

HTPASSWD_FILE="${HTPASSWD_FILE:-/opt/stack/nginx/.htpasswd_mcp}"
MCP_URL="${MCP_URL:-https://<your-domain>/paprika/mcp}"

# URL-safe password (no shell-special chars, no '+/=' from base64 alphabet
# that confuse some config parsers when unquoted).
password="$(python3 -c "import secrets,string;a=string.ascii_letters+string.digits+'_-';print(''.join(secrets.choice(a) for _ in range(40)))")"

# Add (or update) the htpasswd entry with bcrypt.
sudo htpasswd -bB "$HTPASSWD_FILE" "$user" "$password" >/dev/null

auth_b64="$(printf '%s:%s' "$user" "$password" | base64 -w0)"

# Per-tool connection snippet.
snippet=""
case "$tool" in
  claude-code)
    snippet="$(cat <<EOF
# Claude Code (CLI):
claude mcp add --transport http --scope user paprika '${MCP_URL}' \\
  --header 'Authorization: Basic ${auth_b64}'
EOF
)"
    ;;
  claude-desktop)
    snippet="$(cat <<EOF
# Claude Desktop (claude_desktop_config.json):
{
  "mcpServers": {
    "paprika": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "${MCP_URL}",
               "--header", "Authorization: Basic ${auth_b64}"]
    }
  }
}
EOF
)"
    ;;
  gemini-cli)
    snippet="$(cat <<EOF
# Gemini CLI:
gemini mcp add --transport http --scope user paprika '${MCP_URL}' \\
  --header 'Authorization: Basic ${auth_b64}'

# OR settings.json:
{
  "mcpServers": {
    "paprika": {
      "httpUrl": "${MCP_URL}",
      "headers": {
        "Authorization": "Basic ${auth_b64}"
      }
    }
  }
}
EOF
)"
    ;;
  vscode-copilot)
    snippet="$(cat <<EOF
# VS Code Copilot (.vscode/mcp.json or user settings):
{
  "servers": {
    "paprika": {
      "type": "http",
      "url": "${MCP_URL}",
      "headers": {
        "Authorization": "Basic ${auth_b64}"
      }
    }
  }
}
EOF
)"
    ;;
  antigravity)
    snippet="$(cat <<EOF
# Google Antigravity (MCP connection config):
{
  "mcpServers": {
    "paprika": {
      "httpUrl": "${MCP_URL}",
      "headers": {
        "Authorization": "Basic ${auth_b64}"
      }
    }
  }
}
EOF
)"
    ;;
  homeassistant)
    snippet="$(cat <<EOF
# Home Assistant — Settings → Devices & Services → Add Integration → "Model Context Protocol"
#   URL:        ${MCP_URL}
#   Username:   ${user}
#   Password:   ${password}
EOF
)"
    ;;
  claude-web)
    snippet="$(cat <<EOF
# Claude.ai (web) — Settings → Connectors → Add custom connector:
#   URL:        ${MCP_URL}
#   Auth type:  Custom header
#   Header:     Authorization: Basic ${auth_b64}
EOF
)"
    ;;
  gemini-web)
    snippet="$(cat <<EOF
# Gemini (web) — Custom MCP connector:
#   URL:        ${MCP_URL}
#   Header:     Authorization: Basic ${auth_b64}
EOF
)"
    ;;
  *)
    snippet="# (No template for tool '${tool}'. Use creds below manually.)"
    ;;
esac

# Write credential file (gitignored — tmp/ is in .gitignore).
mkdir -p tmp/credentials
chmod 700 tmp/credentials
cred_file="tmp/credentials/${user}.txt"
{
  echo "# MCP client credential — generated $(date -Iseconds)"
  echo "user:           ${user}"
  echo "password:       ${password}"
  echo "auth_b64:       ${auth_b64}"
  echo "url:            ${MCP_URL}"
  echo
  echo "${snippet}"
} > "${cred_file}"
chmod 600 "${cred_file}"

echo "✓ added htpasswd entry for ${user}"
echo "  credentials saved to: ${cred_file}"
echo
cat "${cred_file}"
