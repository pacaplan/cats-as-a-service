# Frontend Agent Guidelines (Next.js)

## Directory Structure

```
apps/web/
├── app/           # Next.js App Router pages
├── components/    # Reusable UI components
├── data/          # Static data and fixtures
└── ...
```

## Conventions

1. **CSS Modules**: Use `*.module.css` for component-scoped styles
2. **Component Organization**: Group by feature (cart/, catalog/, checkout/)
3. **Keep components focused**: Prefer composition over large monolithic components

## Naming Conventions

- **TypeScript/React**: camelCase for functions/variables, PascalCase for components
- **CSS Modules**: camelCase for class names (`.cartButton`, `.heroTitle`)

## Adding a New Feature

1. Create component(s) in `components/`
2. Add page in `app/` if needed
3. Use CSS Modules for styling

## UI Testing

When updating UI components or pages:

1. Use the cursor browser tool to verify changes work correctly
2. Interact with elements to test functionality (clicks, forms, navigation)
3. Take screenshots to confirm visual appearance when appropriate

## Health Check Endpoint

The frontend provides a health check API route for troubleshooting:

**Route:** `GET /api/health`

**Purpose:** Aggregates health status from frontend and backend services

**Checks:**
- Frontend service status
- Backend API connectivity and response time
- Full backend health details (including database and engines)
