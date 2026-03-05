#!/bin/sh
set -e

DEFAULTS_FILE="$HOME/.hcl-commerce/defaults"
SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
MCP_REPO="https://github.com/hcl-team-dev-org/hcl-commerce-mcp.git"
MCP_INSTALL_DIR="$HOME/.hcl-commerce/mcp"

# Load saved defaults
if [ -f "$DEFAULTS_FILE" ]; then
  . "$DEFAULTS_FILE"
fi

# Set built-in defaults for values not yet saved
: "${HCL_MCP_PATH:=$MCP_INSTALL_DIR/main/build/index.js}"
: "${HCL_HOST_URL:=https://commerce-preview.comdx.demo.com}"
: "${HCL_STORE_ID:=41}"
: "${HCL_CATALOG_ID:=11501}"
: "${HCL_CONTRACT_ID:=-41005}"
: "${HCL_FULFILLMENT_CENTER:=R00B2C}"
: "${HCL_STORE_NAME:=Ruby}"
: "${HCL_COMMERCE_VERSION:=commerce-plus}"
: "${HCL_CURRENCY:=USD}"

prompt() {
  _var="$1"
  _label="$2"
  _current=$(eval echo "\$$_var")
  if [ -n "$_current" ]; then
    printf "  %s [%s]: " "$_label" "$_current"
  else
    printf "  %s: " "$_label"
  fi
  read -r _input
  [ -n "$_input" ] && eval "$_var=\"\$_input\""
}

echo ""
echo "HCL Commerce Demo Bootstrap"
echo "==========================="
echo ""
echo "HCL Commerce environment:"
prompt HCL_HOST_URL           "Host URL"
prompt HCL_STORE_ID           "Store ID"
prompt HCL_CATALOG_ID         "Catalog ID"
prompt HCL_CONTRACT_ID        "Contract ID"
prompt HCL_FULFILLMENT_CENTER "Fulfillment center"
prompt HCL_STORE_NAME         "Store name"
prompt HCL_COMMERCE_VERSION   "Commerce version"
prompt HCL_CURRENCY           "Currency"

# Validate required fields
for _field in HCL_HOST_URL HCL_STORE_ID HCL_CATALOG_ID; do
  if [ -z "$(eval echo "\$$_field")" ]; then
    echo "Error: $_field is required." >&2
    exit 1
  fi
done

# Install MCP server if not found at the specified path
if [ ! -f "$HCL_MCP_PATH" ]; then
  echo ""
  echo "MCP server not found — installing..."
  if [ -d "$MCP_INSTALL_DIR/.git" ]; then
    echo "  Updating existing clone..."
    git -C "$MCP_INSTALL_DIR" pull
  else
    mkdir -p "$MCP_INSTALL_DIR"
    git clone "$MCP_REPO" "$MCP_INSTALL_DIR"
  fi
  (cd "$MCP_INSTALL_DIR/main" && npm install && npm run build)
  HCL_MCP_PATH="$MCP_INSTALL_DIR/main/build/index.js"
  echo "  MCP server ready."
fi

# Save as new defaults
mkdir -p "$(dirname "$DEFAULTS_FILE")"
cat > "$DEFAULTS_FILE" << EOF
HCL_HOST_URL='$HCL_HOST_URL'
HCL_STORE_ID='$HCL_STORE_ID'
HCL_CATALOG_ID='$HCL_CATALOG_ID'
HCL_CONTRACT_ID='$HCL_CONTRACT_ID'
HCL_FULFILLMENT_CENTER='$HCL_FULFILLMENT_CENTER'
HCL_STORE_NAME='$HCL_STORE_NAME'
HCL_COMMERCE_VERSION='$HCL_COMMERCE_VERSION'
HCL_CURRENCY='$HCL_CURRENCY'
HCL_MCP_PATH='$HCL_MCP_PATH'
EOF

# Scaffold Next.js project into current directory
echo ""
echo "Creating Next.js project..."
npx create-next-app@latest . \
  --typescript \
  --app \
  --tailwind \
  --eslint \
  --no-src-dir \
  --import-alias "@/*" \
  --yes

# Write .mcp.json
cat > .mcp.json << EOF
{
  "mcpServers": {
    "hcl-commerce": {
      "command": "node",
      "args": ["$HCL_MCP_PATH"],
      "env": {
        "HCL_HOST_URL": "$HCL_HOST_URL",
        "HCL_STORE_ID": "$HCL_STORE_ID",
        "HCL_CATALOG_ID": "$HCL_CATALOG_ID",
        "HCL_CONTRACT_ID": "$HCL_CONTRACT_ID",
        "HCL_TRANSACTION_CONTEXT": "/wcs/resources",
        "HCL_SEARCH_CONTEXT": "/search/resources",
        "HCL_CURRENCY": "$HCL_CURRENCY",
        "HCL_COMMERCE_VERSION": "$HCL_COMMERCE_VERSION",
        "HCL_STORE_NAME": "$HCL_STORE_NAME",
        "HCL_FULFILLMENT_CENTER": "$HCL_FULFILLMENT_CENTER"
      }
    }
  }
}
EOF

# Install skills
mkdir -p .claude/commands
installed=0
for file in "$SKILL_DIR/.claude/commands/"*.md; do
  [ -f "$file" ] && cp "$file" .claude/commands/ && installed=$((installed + 1))
done

# Copy CLAUDE.md template
[ -f "$SKILL_DIR/templates/CLAUDE.md" ] && cp "$SKILL_DIR/templates/CLAUDE.md" CLAUDE.md

echo ""
echo "Done."
echo "  Project:  $(pwd)"
echo "  Skills:   $installed installed"
echo "  MCP:      configured"
echo ""
echo "Open this folder in Claude Code, then run /hcl-setup."
echo ""
