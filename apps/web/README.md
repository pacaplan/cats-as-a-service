# Cat-alog UI Prototype

A Next.js 16 UI-only prototype for the Cat-alog browsing feature.

## Getting Started

### Prerequisites

- Node.js 18+ 
- pnpm (recommended) or npm

### Installation

```bash
cd apps/web
pnpm install
```

### Development

```bash
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) to view the app.

### Build

```bash
pnpm build
pnpm start
```

## Project Structure

```
apps/web/
├── app/
│   ├── layout.tsx          # Root layout with fonts + global styles
│   ├── page.tsx            # Cat-alog home page
│   └── globals.css         # CSS variables + global styles
├── components/
│   ├── layout/             # Header, Footer
│   ├── catalog/            # Hero, CatGrid, CatCard, FilterPills, SidePanel
│   ├── cart/               # CartButton, MiniCart
│   └── ui/                 # Reusable Button component
└── data/
    └── cats.ts             # Hard-coded cat data
```

## Features

- UI-only prototype with hard-coded data
- Responsive cat grid layout
- Interactive mini cart dropdown
- Static navigation (no routing beyond home page)
- CSS Modules for component styling
- Lucide React for icons

## Notes

This is a UI-only prototype. All interactions are non-functional placeholders:
- Cart button shows static count badge
- Mini cart dropdown toggles on click (UI only)
- "Add to cart" / "View details" buttons are non-functional
- Navigation links are static

