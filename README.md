# hcl-commerce-skill

Claude Code skills for building HCL Commerce storefronts in Next.js.

These are slash commands that give Claude deep HCL Commerce knowledge — API patterns, data shapes, common pitfalls, and Next.js App Router conventions — so it can build a working, vertical-specific storefront fast.

## Prerequisites

- Claude Code
- GitHub CLI (`gh`) with access to this repo

Install `gh` if needed:

```sh
brew install gh
```

Then authenticate:

```sh
gh auth login
```

Choose **GitHub.com → HTTPS → Login with a web browser** and follow the prompts. You only need to do this once per machine.

## Quickstart

```sh
gh api repos/hcl-team-dev-org/hcl-commerce-skill/contents/bootstrap.sh -H "Accept: application/vnd.github.raw" | sh
```

This will:
1. Prompt for a projects directory (default `~/demos`) and project name
2. Prompt for your HCL Commerce environment config (saved as defaults for next time)
3. Install the MCP server to `~/.hcl-commerce/mcp/` if not already present
4. Scaffold a Next.js App Router project
5. Write `.mcp.json` and install the skill files

Then open the project folder in Claude Code and run `/hcl-setup`.

## Adding skills to an existing project

From the root of an existing Next.js project:

```sh
gh api repos/hcl-team-dev-org/hcl-commerce-skill/contents/install.sh -H "Accept: application/vnd.github.raw" | sh
```

## Usage

With Claude Code open in your project:

1. **`/hcl-brief`** — run this first. Describes the prospect and what you're building, and creates a `STOREFRONT.md` brief that all subsequent skills read for design and creative direction. Can also be seeded directly: `/hcl-brief high-end fashion retailer, editorial, minimal`.

2. **`/hcl-setup`** — sets up the API client, session handling, image helpers, and environment variables. Verifies the MCP connection is working before writing any code.

3. **`/hcl-plp`** — builds a Product Listing Page. Queries the live API via MCP to understand real data shapes before generating code.

4. **`/hcl-pdp`** — product detail page with variant selection and inventory.

5. **`/hcl-cart`** — cart context, sidebar, and cart page.

6. **`/hcl-checkout`** — streamlined checkout flow (address → shipping → payment → submit).

7. **`/hcl-search`** — search results page.

8. **`/hcl-categories`** — category navigation component.

9. **`/hcl-inventory`** — inventory display patterns (handles both Commerce+ and 9.x).

## How it works

Each skill is a prompt file that Claude executes when you run the slash command. Before writing code, each skill instructs Claude to call the relevant MCP tools to inspect real API responses from the connected environment — so the code it produces is grounded in actual data, not assumptions.

## MCP server

The MCP server that powers the live API calls during a session is at [hcl-commerce-mcp](https://github.com/hcl-team-dev-org/hcl-commerce-mcp). Configure it in your project via `.mcp.json`.
