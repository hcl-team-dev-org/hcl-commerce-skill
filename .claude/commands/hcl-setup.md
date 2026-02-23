You are setting up a Next.js App Router project to connect to an HCL Commerce backend. The MCP server for this session is already configured and pointing at a live HCL Commerce environment.

## Verify the connection first

Call `get_categories` via the MCP tool. If it fails, stop and tell the user — the MCP server must be working before setup can continue. Also call `get_currency_format` to get the currency symbol and decimal places for this store.

## Environment variables

Create `.env.local`. Use the values from the connected MCP environment — the user can confirm them if unsure:

```env
HCL_HOST_URL=                      # e.g. https://your-store.com:6443
HCL_STORE_ID=                      # numeric store ID
HCL_CATALOG_ID=                    # numeric catalog ID
HCL_CONTRACT_ID=                   # e.g. -41005
HCL_TRANSACTION_CONTEXT=/wcs/resources
HCL_SEARCH_CONTEXT=/search/resources
HCL_CURRENCY=USD
HCL_COMMERCE_VERSION=commerce-plus  # or commerce-9x
HCL_FULFILLMENT_CENTER=             # Commerce+ only, e.g. R00B2C
```

Add `.env.local` to `.gitignore` if not already there.

## Next.js configuration

Update `next.config.ts` to allow images from the commerce host:

```typescript
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: new URL(process.env.HCL_HOST_URL!).hostname,
      },
    ],
  },
}

export default nextConfig
```

## API client

Create `lib/commerce/client.ts`. This is the foundation everything else builds on:

```typescript
const HOST = process.env.HCL_HOST_URL!
const STORE_ID = process.env.HCL_STORE_ID!
const TX_CTX = process.env.HCL_TRANSACTION_CONTEXT!
const SEARCH_CTX = process.env.HCL_SEARCH_CONTEXT!

export const TRANSACTION_BASE = `${HOST}${TX_CTX}/store/${STORE_ID}`
export const SEARCH_BASE = `${HOST}${SEARCH_CTX}/store/${STORE_ID}`

export async function commerceFetch<T>(
  url: string,
  options: RequestInit & { tokens?: { wcToken: string; wcTrustedToken: string } } = {}
): Promise<T> {
  const { tokens, ...fetchOptions } = options
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(fetchOptions.headers as Record<string, string>),
  }
  if (tokens) {
    headers['WCToken'] = tokens.wcToken
    headers['WCTrustedToken'] = tokens.wcTrustedToken
  }
  const res = await fetch(url, { ...fetchOptions, headers })
  if (!res.ok) {
    const body = await res.text()
    throw new Error(`Commerce API error ${res.status}: ${body}`)
  }
  return res.json()
}
```

## Guest session

Tokens are required for cart and checkout. Keep them server-side — never expose `WCToken` / `WCTrustedToken` to client JavaScript.

Create `lib/commerce/session.ts`:

```typescript
import { TRANSACTION_BASE, commerceFetch } from './client'

export interface GuestSession {
  wcToken: string
  wcTrustedToken: string
  userId: string
}

export async function createGuestSession(): Promise<GuestSession> {
  const data = await commerceFetch<any>(
    `${TRANSACTION_BASE}/guestidentity`,
    { method: 'POST', body: JSON.stringify({}) }
  )
  return {
    wcToken: data.WCToken,
    wcTrustedToken: data.WCTrustedToken,
    userId: data.userId,
  }
}
```

Create `app/api/commerce/session/route.ts` — this initialises a guest session and sets httpOnly cookies:

```typescript
import { NextResponse } from 'next/server'
import { cookies } from 'next/headers'
import { createGuestSession } from '@/lib/commerce/session'

export async function POST() {
  const session = await createGuestSession()
  const cookieStore = await cookies()
  cookieStore.set('wc_token', session.wcToken, { httpOnly: true, sameSite: 'lax' })
  cookieStore.set('wc_trusted_token', session.wcTrustedToken, { httpOnly: true, sameSite: 'lax' })
  cookieStore.set('wc_user_id', session.userId, { httpOnly: true, sameSite: 'lax' })
  return NextResponse.json({ ok: true })
}
```

Create `lib/commerce/getTokens.ts` — used by Route Handlers that need to attach tokens:

```typescript
import { cookies } from 'next/headers'

export async function getTokens() {
  const cookieStore = await cookies()
  return {
    wcToken: cookieStore.get('wc_token')?.value ?? '',
    wcTrustedToken: cookieStore.get('wc_trusted_token')?.value ?? '',
    userId: cookieStore.get('wc_user_id')?.value ?? '',
  }
}
```

## Image URLs

HCL Commerce image paths in API responses are relative (e.g. `/hclstore/images/foo.jpg`). Create `lib/commerce/images.ts`:

```typescript
export function getImageUrl(path: string | undefined): string {
  if (!path) return '/placeholder.jpg'
  if (path.startsWith('http')) return path
  return `${process.env.HCL_HOST_URL}${path}`
}
```

Always use this helper — never construct image URLs inline.

## Confirm setup

When done, tell the user what was created and confirm the MCP connection is working. The project is now ready for `/hcl-plp`, `/hcl-pdp`, `/hcl-cart`, and `/hcl-checkout`.
