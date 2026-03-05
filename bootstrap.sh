#!/bin/sh
set -e

DEFAULTS_FILE="$HOME/.hcl-commerce/defaults"
SKILL_REPO="hcl-team-dev-org/hcl-commerce-skill"
MCP_REPO="https://github.com/hcl-team-dev-org/hcl-commerce-mcp.git"
MCP_INSTALL_DIR="$HOME/.hcl-commerce/mcp"

# Load saved defaults
if [ -f "$DEFAULTS_FILE" ]; then
  . "$DEFAULTS_FILE"
fi

# Set built-in defaults for values not yet saved
: "${HCL_MCP_PATH:=$MCP_INSTALL_DIR/build/index.js}"
: "${HCL_HOST_URL:=https://commerce-preview.comdx.demo.com}"
: "${HCL_STORE_ID:=41}"
: "${HCL_CATALOG_ID:=11501}"
: "${HCL_CONTRACT_ID:=-41005}"
: "${HCL_FULFILLMENT_CENTER:=R00B2C}"
: "${HCL_STORE_NAME:=Ruby}"
: "${HCL_COMMERCE_VERSION:=commerce-9x}"
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
  read -r _input || true
  if [ -n "$_input" ]; then
    eval "$_var=\"\$_input\""
  fi
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
  _val=$(eval echo "\$$_field")
  if [ -z "$_val" ]; then
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
  (cd "$MCP_INSTALL_DIR" && npm install && npm run build)
  HCL_MCP_PATH="$MCP_INSTALL_DIR/build/index.js"
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

# Install skills from GitHub
mkdir -p .claude/commands
installed=0
SKILLS="hcl-brief hcl-setup hcl-plp hcl-pdp hcl-cart hcl-checkout hcl-search hcl-inventory hcl-categories"
for skill in $SKILLS; do
  if gh api "repos/$SKILL_REPO/contents/.claude/commands/$skill.md" -H "Accept: application/vnd.github.raw" > ".claude/commands/$skill.md" 2>/dev/null; then
    installed=$((installed + 1))
  else
    rm -f ".claude/commands/$skill.md"
  fi
done

# Fetch CLAUDE.md template from GitHub
gh api "repos/$SKILL_REPO/contents/templates/CLAUDE.md" -H "Accept: application/vnd.github.raw" > CLAUDE.md 2>/dev/null || true

echo ""
echo "Done."
echo "  Project:  $(pwd)"
echo "  Skills:   $installed installed"
echo "  MCP:      configured"
echo ""
echo "Open this folder in Claude Code, then run /hcl-setup."
echo ""
