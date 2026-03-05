Create a `STOREFRONT.md` brief for this demo project.

If `$ARGUMENTS` is provided, treat it as the initial description of the prospect and what they sell — use it to seed the brief without asking for a description first.

If `$ARGUMENTS` is empty, start by asking: *"Describe the prospect and what you're building for them — industry, what they sell, and any characteristics that define their brand."*

If `STOREFRONT.md` already exists, read it first, summarise what's there, and ask whether to update it or start fresh.

---

## What the brief must cover

### The prospect
One sentence: who this is for and what they sell.

### What they sell
Products, categories, rough scale. Any constraints that change the build — e.g. "only 4 products", "single hero product", "hundreds of SKUs across 6 categories".

### Brand tone
How the brand speaks and feels. Infer from the description where possible:
- "luxury fashion" → aspirational, restrained, confident
- "own-branded electronics" → technical precision, minimal, authoritative
- "outdoor/trail running" → performance-focused, direct, energetic

Ask only if genuinely unclear.

### Visual direction
Make specific, opinionated choices — not vague ones. Useful: *"Large-format editorial imagery, sparse text, dark navy and white with a single warm accent"*. Not useful: *"modern and clean"*.

Cover: colour palette approach, typography weight/style, imagery role, whitespace vs density, grid behaviour.

### UI library
Ask the user directly — this is a technical choice they need to make. Recommend **Tailwind CSS + shadcn/ui** as the default if they have no preference.

### Page emphasis
Tailor this specifically to the vertical. Think about what actually drives this type of customer to buy:

- **PLP:** grid density, filtering importance (facets or minimal?), imagery weight, browse-first vs quick-add
- **PDP:** what matters here — technical specs, size/variant selection, large imagery, social proof, urgency signals, comparison?
- **Homepage:** does it matter for this demo or can it be a simple hero + category grid?
- **Checkout:** any particular requirements — guest checkout, B2B quantities, express options?

### Constraints
Capture anything that changes the default build. Infer from the description rather than asking:
- Few products → no pagination, no faceted filtering
- Single brand → no brand filter on PLP
- B2B → quantity inputs, pricing tier display
- No search needed → omit search UI

Be explicit about constraints so skills don't build things that aren't needed.

---

## How to write it

Be specific and opinionated throughout. The brief exists so every skill that runs after this produces consistent, intentional output without needing creative direction each time. Vague briefs produce vague storefronts.

Make reasonable assumptions for anything the user hasn't specified — don't ask for every detail. Show what you assumed so they can correct it.

---

## When done

Show the user the `STOREFRONT.md` you wrote. Ask: *"Does this capture what you have in mind, or is there anything to adjust?"*

Refine based on their response, then write the final version to `STOREFRONT.md`.
