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

Create an empty folder for your demo project and run from inside it:

```sh
mkdir my-demo && cd my-demo
bash <(gh api repos/hcl-team-dev-org/hcl-commerce-skill/contents/bootstrap.sh -H "Accept: application/vnd.github.raw")
```

This will:
1. Prompt for HCL Commerce environment config — all fields pre-filled with demo defaults, just hit Enter to accept
2. Install the MCP server to `~/.hcl-commerce/mcp/` if not already present
3. Scaffold a Next.js App Router project into the current folder
4. Write `.mcp.json` and install the skill files

Then open the folder in Claude Code and run `/hcl-setup`.

## Skills

With Claude Code open in your project:

**Available:**

- **`/hcl-brief`** — run this first. Describe the prospect and what you're building; creates `STOREFRONT.md` that all subsequent skills use for design direction. Can be seeded inline: `/hcl-brief high-end fashion retailer, editorial, minimal`.
- **`/hcl-setup`** — sets up the API client, session handling, and image helpers. Verifies the MCP connection before writing any code.
- **`/hcl-plp`** — Product Listing Page. Queries the live API via MCP to inspect real data shapes before generating code.

**Coming soon:**

- `/hcl-pdp` — product detail page with variant selection and inventory
- `/hcl-cart` — cart context, sidebar, and cart page
- `/hcl-checkout` — streamlined checkout flow
- `/hcl-search` — search results page
- `/hcl-categories` — category navigation
- `/hcl-inventory` — inventory display patterns (Commerce+ and 9.x)

## How it works

Each skill is a prompt file Claude executes when you run the slash command. Before writing code, each skill instructs Claude to call MCP tools to inspect real API responses from the connected environment — so the code it produces matches actual data shapes, not assumptions.
