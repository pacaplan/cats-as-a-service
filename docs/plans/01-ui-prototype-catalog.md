# Next.js Cat-alog UI Prototype

## Scope

Implement the Cat-alog Browsing feature (functional spec section 3.1) as a UI-only prototype using Next.js. Convert the existing [catalog.html](docs/cat_app/mockups/catalog.html) mockup into React components with hard-coded data.

## Tech Stack

- **Framework**: Next.js 16 (App Router, Turbopack)
- **Package Manager**: pnpm
- **Styling**: CSS Modules (co-located `.module.css` files per component)
- **Icons**: Lucide React (replacing iconify)

## Directory Structure

```
apps/web/
├── app/
│   ├── layout.tsx          # Root layout with fonts + global styles
│   ├── page.tsx            # Cat-alog home page
│   └── globals.css         # CSS variables + global styles from mockup
├── components/
│   ├── layout/
│   │   ├── Header.tsx      # Logo, nav, auth link, cart button
│   │   └── Footer.tsx      # Footer links + disclaimer
│   ├── catalog/
│   │   ├── Hero.tsx        # Hero banner with CTAs
│   │   ├── CatGrid.tsx     # Grid container
│   │   ├── CatCard.tsx     # Individual cat card
│   │   ├── FilterPills.tsx # Filter badges (decorative)
│   │   └── SidePanel.tsx   # Quiz CTA + info section
│   ├── cart/
│   │   ├── CartButton.tsx  # Cart icon + count badge
│   │   └── MiniCart.tsx    # Dropdown cart preview
│   └── ui/
│       └── Button.tsx      # Reusable button component
├── data/
│   └── cats.ts             # Hard-coded cat data (6 cats from mockup)
├── package.json
├── tsconfig.json
└── next.config.js
```

## Key Implementation Details

### Styling Approach

Extract CSS variables from `catalog.html` lines 13-43 into `globals.css`. Use Inter font via `next/font/google`. Component styles via CSS Modules.

### Hard-coded Data

Create `data/cats.ts` with the 6 cats from the mockup:

- Nebula Neko (48.00 cents)
- Laser Pointer Prodigy (39.00 cents)  
- Clockwork Catnapper (42.00 cents)
- Whisker Wizard (51.00 cents)
- Loaf Mode Deluxe (29.00 cents)
- Glitch in the Catrix (37.00 cents)

### Component Props

`CatCard` will receive props matching the functional data model:

```tsx
interface CatCardProps {
  name: string;
  description: string;
  imageUrl: string;
  price: number;
  tag: string;
}
```

### Interactivity (UI-only)

- Cart button shows static count badge
- Mini cart dropdown toggles on click (useState)
- "Add to cart" / "View details" buttons are non-functional placeholders
- Navigation links are static (no routing beyond home page)