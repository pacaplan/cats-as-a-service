# Add Cart, Checkout, and FAQ Pages with Routing

## Route Structure

Create three new pages using Next.js App Router:

- `/cart` - [apps/web/app/cart/page.tsx](apps/web/app/cart/page.tsx)
- `/checkout` - [apps/web/app/checkout/page.tsx](apps/web/app/checkout/page.tsx)
- `/faq` - [apps/web/app/faq/page.tsx](apps/web/app/faq/page.tsx)

## Implementation Approach

### 1. Update Header for Navigation

Modify [apps/web/components/layout/Header.tsx](apps/web/components/layout/Header.tsx):

- Add `activePage` prop to highlight current nav item
- Replace div nav links with Next.js `Link` components
- Routes: Cat-alog → `/`, CatBot → `/catbot` (placeholder), FAQ → `/faq`
- Logo links to home `/`

### 2. Update Footer for Navigation

Modify [apps/web/components/layout/Footer.tsx](apps/web/components/layout/Footer.tsx):

- FAQ link → `/faq`
- Other links remain as non-functional placeholders (external links)

### 3. Create Cart Page Components

New files in `apps/web/components/cart/`:

- `CartItem.tsx` + `CartItem.module.css` - Individual cart item row
- `CartSummary.tsx` + `CartSummary.module.css` - Order summary sidebar (reused in checkout)

New file `apps/web/app/cart/page.tsx` + `page.module.css`:

- Hero with cart-specific copy
- Cart items list (static data from [data/cats.ts](apps/web/data/cats.ts))
- "Continue to pretend checkout" → `/checkout`
- "Keep browsing cats" → `/`

### 4. Create Checkout Page Components

New files in `apps/web/components/checkout/`:

- `CheckoutHero.tsx` + CSS - Hero with step indicators
- `ContactSection.tsx` + CSS - Contact details form (UI only)
- `DeliverySection.tsx` + CSS - Delivery universe form (UI only)
- `PaymentSection.tsx` + CSS - Payment radio options

New file `apps/web/app/checkout/page.tsx` + `page.module.css`:

- "Back to cart" → `/cart`
- "Keep browsing cats" → `/`

### 5. Create FAQ Page Components

New files in `apps/web/components/faq/`:

- `FAQItem.tsx` + `FAQItem.module.css` - Individual FAQ accordion item
- `FAQAside.tsx` + `FAQAside.module.css` - Sidebar with about/CTA sections

New file `apps/web/app/faq/page.tsx` + `page.module.css`:

- "Return to Cat-alog" → `/`
- "Jump to CatBot flow" → `/catbot` (placeholder)

### 6. Update Existing Components

**CatCard** ([apps/web/components/catalog/CatCard.tsx](apps/web/components/catalog/CatCard.tsx)):

- "Add to cart" button navigates to `/cart` using Next.js Link

**MiniCart** ([apps/web/components/cart/MiniCart.tsx](apps/web/components/cart/MiniCart.tsx)):

- "View cart" → `/cart`
- "Checkout" → `/checkout`

### 7. Create Shared Hero Component

Refactor to create a generic `PageHero.tsx` in `apps/web/components/layout/` that accepts title, subtitle, and optional meta text - used across cart, checkout, and FAQ pages.

## Static Data

Cart and checkout pages will use the first 2 cats from [data/cats.ts](apps/web/data/cats.ts) (Nebula Neko, Laser Pointer Prodigy) as static cart contents - matching the mockups.

## Navigation Map

| Component/Button | Target Route |
|-----------------|--------------|
| Logo | `/` |
| Nav: Cat-alog | `/` |
| Nav: CatBot | `/catbot` (placeholder) |
| Nav: FAQ | `/faq` |
| "Add to cart" | `/cart` |
| Mini-cart "View cart" | `/cart` |
| Mini-cart "Checkout" | `/checkout` |
| Cart "Continue to checkout" | `/checkout` |
| Cart "Keep browsing" | `/` |
| Checkout "Back to cart" | `/cart` |
| FAQ "Return to Cat-alog" | `/` |
| Footer FAQ | `/faq` |