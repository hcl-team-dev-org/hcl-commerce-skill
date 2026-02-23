#!/bin/sh
set -e

REPO="hcl-team-dev-org/hcl-commerce-skill"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/.claude/commands"

SKILLS="hcl-setup hcl-plp hcl-pdp hcl-cart hcl-checkout hcl-search hcl-inventory hcl-categories"

mkdir -p .claude/commands

installed=0
skipped=0

for skill in $SKILLS; do
  url="$BASE_URL/$skill.md"
  target=".claude/commands/$skill.md"
  http_status=$(curl -s -o "$target" -w "%{http_code}" "$url")
  if [ "$http_status" = "200" ]; then
    echo "  installed /$skill"
    installed=$((installed + 1))
  else
    rm -f "$target"
    skipped=$((skipped + 1))
  fi
done

echo ""
echo "HCL Commerce skills installed: $installed (skipped unavailable: $skipped)"
echo "Run /hcl-setup in Claude Code to get started."
