Build a Product Listing Page for this Next.js App Router project connected to HCL Commerce.

Assume `/hcl-setup` has already been run. The foundation (`lib/commerce/client.ts`, `lib/commerce/images.ts`, `.env.local`) should already exist.

## Understand the real data first

Before writing any code, use the MCP tools to inspect actual API responses from the connected environment:

1. `get_categories` — identify available categories. Pick one that has products.
2. `get_products_by_category` with that category's numeric ID — inspect the full response. The product list is in `catalogEntryView`. Note the fields available: `partNumber`, `name`, `thumbnail`, `shortDescription`, `seo`, `price`.
3. `get_product_details` on 3–4 part numbers from step 2 — this reveals the full product structure including `items` (the child SKUs) and `attributes` (look for `usage: "Defining"` — these are variant axes like size, colour).
4. `get_display_prices` on those part numbers — note the structure of list price vs offer price.
5. `get_inventory` on the SKU `partNumber` values from the `items` in step 3 — confirm what inventory data looks like for this environment.

Use what you actually see in these responses to inform the code. Field names and shapes vary between Commerce+ and 9.x environments.

## Critical rules

**Category ID vs SEO slug.** Route parameters may be SEO slugs (e.g. `running-shoes`) but the products API only accepts numeric category IDs (e.g. `3074457345616677684`). When building navigation links to the PLP, pass the numeric `uniqueID` as a search param alongside the slug. Never pass a slug directly to the products API.

**Batch sizes.** `get_product_details`, `get_display_prices`, and `get_inventory` all have URL length limits. Batch at 20 part numbers per request maximum.

**Inventory version.** Check `HCL_COMMERCE_VERSION` in env:
- `commerce-plus` → inventory endpoint is `/inventory/api/v1/item-inventories`, requires fulfillment center
- `commerce-9x` → inventory endpoint is `/wcs/resources/store/{storeId}/inventoryavailability/byPartNumber`

**Images.** Always use `getImageUrl()` from `lib/commerce/images.ts`. Never construct image URLs inline.

**Prices.** Prefer offer price over list price when both are present. Format using the currency info from `get_currency_format`.

## Data fetching

Create `lib/commerce/products.ts` with typed server-side functions. Keep fetch calls out of the page component itself. Use `cache: 'no-store'` for demo freshness — you want to see real data every time.

The core call sequence for a PLP is:
1. Fetch product list by category ID (search API, returns `catalogEntryView` with summary data)
2. Fetch full product details for the returned part numbers (transaction API, batched)
3. Fetch display prices for those part numbers (transaction API, batched)
4. Optionally fetch inventory for SKU part numbers from the product details

The product list response may already include price data. Check what you saw in the MCP call — if prices are there, avoid the extra round-trip.

## What to build

**`app/products/[categoryId]/page.tsx`** — Next.js Server Component. Accepts `categoryId` as a route param (numeric ID). Fetches and renders the product grid. Include `searchParams` for pagination (`page` query param, derive offset: `(page - 1) * limit`).

**`components/commerce/ProductCard.tsx`** — displays product image (via `<Image>` from `next/image`), name, price, and a link to the PDP. Keep it clean — this is a demo, the card should look intentional.

**`components/commerce/ProductGrid.tsx`** — responsive grid of `ProductCard` components. Include a loading skeleton state using `loading.tsx` or Suspense.

**`components/commerce/Pagination.tsx`** — prev/next or numbered pagination using URL search params. Server-compatible (no client state for page number).

## Navigation wiring

When you link to the PLP from navigation or category components, pass the numeric `uniqueID` so the page can call the API correctly. If the project already has a navigation component, wire it up. Suggested pattern:

```typescript
// Navigation component
<Link href={`/products/${category.uniqueID}?name=${encodeURIComponent(category.name)}`}>
  {category.name}
</Link>

// PLP page — reads categoryId from params, display name from searchParams
const { categoryId } = await params
const displayName = searchParams.name ?? 'Products'
```

## When done

Confirm what was built. Tell the user which category the PLP is showing data from (based on what the MCP returned). Note that `/hcl-pdp` can be run next to handle product detail pages.
