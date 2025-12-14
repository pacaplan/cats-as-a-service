# Functional Specification: Custom Cat E‑Commerce Application

## 1. Overview

The Custom Cat E‑Commerce Application is a fictional online platform that allows users to browse the Cat-alogue and purchase pre‑made cats or design their own using an AI‑powered CatBot. It includes standard e‑commerce functionality (catalog, cart, checkout), fictional payment processing, daily humorous fulfillment emails, and an admin interface known as the CMS (Cat Management System).&#x20;

This document defines user‑facing and administrative behavior, core functional flows, data models, UI expectations, and constraints.

---

## 2. Core User Personas

- **Guest User**: May browse the cat‑alogue and purchase pre‑made cats. Cannot create or purchase custom cats.
- **Registered User**: May browse, create custom cats via CatBot, purchase both pre‑made and custom cats, and receive ongoing order fulfillment emails.
- **Admin User**: Accesses the Cat Management System for managing pre‑made cats, viewing or moderating user‑generated cats, and maintaining FAQs.

---

## 3. Functional Requirements

### 3.1 Cat‑alogue Browsing

**UI Requirement:** This section must be labeled as **“Cat‑alog”** in the user interface.

Users can browse:

- A list/grid of **pre‑made cats**.
- Individual pre‑made cat detail pages, including:
  - Name
  - Description
  - Image
  - Price

Users may add pre‑made cats to their shopping cart.

Filtering and search are optional stretch features and are out of scope unless explicitly added later.

---

### 3.2 AI CatBot (Build‑Your‑Own Cat)

Only available to registered and logged‑in users.

#### 3.2.1 Cat Personality Quiz (Optional Warm‑Up)

Before entering free‑text mode, users may optionally take a short **Cat Personality Quiz** to help guide the CatBot. This lowers the barrier for users who don't know what to type and generates richer LLM prompts.

**Quiz Flow:**

1. User clicks "Help me find my ideal cat" (or skips directly to free‑text input).
2. User answers 3–4 playful multiple‑choice questions:
   - **Q1:** "What's your ideal cat energy level?"
     - Options: "Lazy loaf", "Playful chaos agent", "Dignified observer", "Zoomies at 3am"
   - **Q2:** "Pick a superpower for your cat:"
     - Options: "Teleportation (into boxes)", "Mind control (for treats)", "Invisibility (when called)", "Time manipulation (nap anywhere)"
   - **Q3:** "Your cat's dream vacation?"
     - Options: "Sunbeam resort", "Cardboard box castle", "The forbidden countertop", "Your keyboard"
   - **Q4:** "Choose a cat aesthetic:"
     - Options: "Elegant tuxedo", "Fluffy cloud", "Mysterious void", "Tiger-striped adventurer"
3. Upon completion, the system generates a **cat personality summary** (e.g., "You matched with: **Chaotic Gremlin**").
4. This summary is used to pre‑seed the CatBot prompt, resulting in more tailored name suggestions and descriptions.
5. Users may still override or refine via free‑text after the quiz.

**UI Requirement:** The quiz result should be shareable (e.g., "I got a Chaotic Gremlin cat! 🐱") to encourage social engagement.

#### 3.2.2 Free‑Text Cat Creation

1. User opens the CatBot interface (or arrives post‑quiz).
2. User is prompted to describe the type of cat they want using natural language.
3. The CatBot (powered by an LLM) will:
   - Interpret user intent.
   - Generate **three suggested names**.
   - Generate a **text description**.
   - Trigger an **image generation** process.
4. The user may:
   - Select one of the suggested names.
   - Edit the selected name.
   - Request modifications ("make it fluffier," "more chaotic energy," etc.).
5. The CatBot regenerates content as needed.
6. Once satisfied, the user may save the cat.
7. The saved custom cat becomes a **product entity** associated with the user.
8. Custom cats may be added to cart for checkout.

---

### 3.3 Shopping Cart

#### Requirements:

- Users may add items (premade or custom) to a persistent cart.
- Guest users **cannot** add custom cats to the cart.
- Cart shows list of items, quantities (always 1 per cat), pricing, and total.
- Because cats are one‑of‑a‑kind:
  - All quantities default to 1.
  - No multi‑quantity purchase option.

---

### 3.4 Checkout

Checkout flow depends on user type:

#### Guest Users:

- Can check out **only with pre‑made cats**.

#### Registered Users:

- Can check out with any combination of pre‑made and custom cats.

#### Fictional Payment

Payment uses obviously non‑real payment brands, such as:

- LaserPointer Express
- CatnipCoin
- MeowCard

No real or test credit card numbers may be accepted.

Order confirmation displays a success page indicating fictional completion.

---

### 3.5 Order Fulfillment

Upon order completion:

1. User receives a humorous confirmation email.
2. User is automatically subscribed to **daily cat status updates**.
3. The system sends daily emails until:
   - The user unsubscribes, or
   - The admin disables a specific order's emails.

Emails are text‑only. No HTML is required.

#### Example Daily Email Messages (3 samples):

- "Your cat is currently practicing dramatic poses. Estimated delivery: eventually."
- "Today's update: your cat discovered a sunbeam and will not be moving for the next 4–8 hours."
- "Cat status: chasing a laser dot of unknown origin, will report more tomorrow."

All emails must include a functional **unsubscribe link**.

#### 3.5.1 Email Subscription Management

To prevent email overload for users with multiple orders, the following rules apply:

**Subscription Model:**
- Email subscriptions are managed **per user**, not per order.
- A single user receives **at most one daily email**, regardless of how many orders they have placed.
- The daily email may reference multiple cats if the user has multiple active orders (e.g., "Your cats are conspiring in the shipping department...").

**Frequency Preferences (Optional):**

Registered users may adjust their update frequency via a link in any email or in account settings:
- **Daily** (default): One email per day with cat status updates.
- **Weekly digest**: A single weekly summary email.
- **Confirmation only**: No ongoing updates; only the initial order confirmation.

**Unsubscribe Behavior:**
- Clicking "unsubscribe" in any email stops **all** daily/weekly cat status updates for that user.
- The user may re‑subscribe via a link in a future order confirmation email.
- Guest users unsubscribe on a per‑order basis (since they have no account).

---

### 3.6 FAQ Page

Publicly visible FAQ with curated humorous content. The FAQ serves dual purposes: providing playful user guidance and functioning as a subtle "about the developer" disclosure for recruiters and hiring managers.

#### Core required Q/A entries:

- **Q:** Is this real?
  **A:** Sure...
- **Q:** Like — really?
  **A:** Of course not, silly!
- **Q:** Then why does this exist?
  **A:** This is an example application for the "Architecture on Rails" framework: https://github.com/pacaplan/rampart.
- **Q:** But I need a cat!
  **A:** There are many excellent models available for adoption! Find the one for you here: https://www.aspca.org/adopt-pet/find-shelter

Admin users may manage FAQ entries via the CMS.

---

## 4. Authentication

The system supports the following login and signup mechanisms:

- Email/password
- Email magic link (passwordless)
- OAuth providers: Google and Apple

Any technology may be used; this specification defines user‑visible behavior only.

No account management (profile editing, password resets, order history) is required for MVP.

---

## 5. Admin CMS (Cat Management System)

Accessible only to authenticated users with admin role.

### 5.1 Manage Pre‑Made Cats

Admin can:

- Create a new pre‑made cat
- Edit name, description, image, and price
- Publish/unpublish
- Archive/delete

### 5.2 View Custom Cats

Admin can:

- View list of all user‑generated custom cats
- Filter by user (optional)
- Inspect details

### 5.3 Delete / Archive Custom Cats

Admin may remove or hide custom cats from public visibility.
User‑generated cats cannot be edited by admin.

### 5.4 Manage FAQs

FAQ management is **not** included in the Admin CMS. FAQ content is fixed in the application and not editable.

---

## 6. Data Model (Functional)

This is a functional model. Field types, storage, and implementation are not defined.

### 6.1 Cat

- **id** (unique identifier)
- **name**
- **description**
- **image\_url**
- **price**
- **type** (premade | custom)
- **created\_at**
- **updated\_at**
- **creator\_user\_id** (nullable; set for custom cats)
- **status** (active | unpublished | archived)

### 6.2 User

- **id**
- **email**
- **authentication\_method** (password, magic link, oauth)
- **oauth\_provider** (nullable)

### 6.3 Cart Item

- **id**
- **user\_id** (nullable for guest carts)
- **cat\_id**
- **created\_at**

### 6.4 Order

- **id**
- **user\_id** (nullable for guest pre‑made purchases)
- **status** (confirmed)
- **created\_at**

### 6.5 Order Item

- **order\_id**
- **cat\_id**

### 6.6 Email Subscription

- **order\_id**
- **email**
- **is\_active** (true/false)
- **unsubscribe\_token**

---

## 7. Non‑Functional Requirements

- **Clarity**: Fictional nature must be obvious throughout checkout.
- **Accessibility**: UI should meet basic accessibility guidelines.
- **Performance**: Reasonable page load times for catalog browsing.
- **Security**: Authentication flows must follow standard patterns.
- **Email Reliability**: Unsubscribe must function consistently.

---

## 8. Out of Scope for MVP

- User profile management
- Payment integrations with real or test gateways
- Order tracking screens
- Inventory or stock control
- Shipping estimations or logistics
- Reviews or ratings
- Multi‑image galleries
- Search or filtering

---

## 9. Summary

This application delivers a playful yet functional e‑commerce experience centered around pre‑made and AI‑generated custom cats. It combines standard e‑commerce flows with humorous daily email updates, a basic yet flexible admin CMS, and a natural language CatBot that interprets user desires creatively.

The scope is intentionally constrained to maintain simplicity while providing opportunity for future expansion if needed.

