# hcl-commerce-skill

Claude Code skills for building HCL Commerce storefronts in Next.js.

These are slash commands that give Claude deep HCL Commerce knowledge — API patterns, data shapes, common pitfalls, and Next.js App Router conventions — so it can build a working, vertical-specific storefront fast.

## Prerequisites

- A Next.js App Router project (the target project you're building the storefront in)
- The HCL Commerce MCP server configured for that project's session (`.mcp.json` in the project root pointing at a live Commerce environment)
- Claude Code

## Install

From the root of your Next.js project:

```sh
curl -s https://raw.githubusercontent.com/YOUR_ORG/hcl-commerce-skill/main/install.sh | sh
```

This copies the skill files into `.claude/commands/` in your project.

## Usage

With Claude Code open in your project:

1. **`/hcl-setup`** — run this first. Sets up the API client, session handling, image helpers, and environment variables. Verifies the MCP connection is working before writing any code.

2. **`/hcl-plp`** — builds a Product Listing Page. Queries the live API via MCP to understand real data shapes before generating code.

3. **`/hcl-pdp`** — product detail page with variant selection and inventory.

4. **`/hcl-cart`** — cart context, sidebar, and cart page.

5. **`/hcl-checkout`** — streamlined checkout flow (address → shipping → payment → submit).

6. **`/hcl-search`** — search results page.

7. **`/hcl-categories`** — category navigation component.

8. **`/hcl-inventory`** — inventory display patterns (handles both Commerce+ and 9.x).

## How it works

Each skill is a prompt file that Claude executes when you run the slash command. Before writing code, each skill instructs Claude to call the relevant MCP tools to inspect real API responses from the connected environment — so the code it produces is grounded in actual data, not assumptions.

## MCP server

The MCP server that powers the live API calls during a session is at [hcl-commerce-mcp](https://github.com/YOUR_ORG/hcl-commerce-mcp). Configure it in your project via `.mcp.json`.
