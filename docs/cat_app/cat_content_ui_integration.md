# Cat & Content BC – UI Integration Checklist

The current `apps/web` UI is a **static mockup** — no backend integration exists yet. These items represent the work needed to connect the UI to the Cat & Content bounded context APIs.


---

## CatBot Access & Functionality

- [ ] Restrict CatBot access to registered/logged-in users only (requirements §3.2)
- [ ] Implement CatBot generation flow that returns three suggested names
- [ ] Implement CatBot generation flow that returns a text description
- [ ] Implement CatBot image generation trigger
- [ ] Allow users to select one of the suggested names
- [ ] Allow users to edit the selected name
- [ ] Allow users to request modifications ("make it fluffier," etc.)
- [ ] Enable saving the custom cat as a product entity
- [ ] Allow adding saved custom cats to cart

---

## Cat Personality Quiz

- [ ] Align quiz questions with requirements spec (4 specific questions with defined options)
  - Q1: "What's your ideal cat energy level?" → Lazy loaf, Playful chaos agent, Dignified observer, Zoomies at 3am
  - Q2: "Pick a superpower for your cat:" → Teleportation (into boxes), Mind control (for treats), Invisibility (when called), Time manipulation (nap anywhere)
  - Q3: "Your cat's dream vacation?" → Sunbeam resort, Cardboard box castle, The forbidden countertop, Your keyboard
  - Q4: "Choose a cat aesthetic:" → Elegant tuxedo, Fluffy cloud, Mysterious void, Tiger-striped adventurer
- [ ] Document all four quiz questions in API spec (`GET /api/catbot/quiz`)
- [ ] Implement shareable quiz result (e.g., "I got a Chaotic Gremlin cat! 🐱")
- [ ] Wire "Share Result" button to copy shareable text or open share dialog

---

## Catalog

- [ ] Implement cat detail page route (`/catalog/:slug`)
- [ ] Wire "View details" button to navigate to detail page
- [ ] Display full cat details: name, description, image, price, profile (age, temperament, traits), media gallery

---

## Page Metadata

- [ ] Set correct page title for CatBot page (currently shows "Cat‑alog")

---

## Filtering (Optional/Stretch)

- [ ] Decide whether to keep or remove filter pills ("All vibes", "Cozy", "Chaotic", "Space‑themed")
- [ ] If keeping, implement backend query support for tag filtering

---

## Documentation Gaps

- [ ] Resolve FAQ management contradiction in requirements (§3.6 says admin can manage; §5.4 says fixed)
- [ ] Create architecture/API docs for Commerce BC (cart, checkout, payments, fulfillment) or note as future BC

---


