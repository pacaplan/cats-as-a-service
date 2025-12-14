# Cat & Content Bounded Context – REST API

This document defines the REST API endpoints for the Cat & Content bounded context.

For architecture and domain details, see [cat_content_architecture.md](./cat_content_architecture.md).

---

## 1. Catalog (Public)

Browse and view premade cats in the catalog.

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/catalog` | List all published premade cats | No |
| `GET` | `/api/catalog/:slug` | Get details of a specific cat by slug | No |

### `GET /api/catalog`

Returns a paginated list of published premade cats.

**Query Parameters:**
- `page` (optional) — Page number (default: 1)
- `per_page` (optional) — Items per page (default: 20, max: 100)
- `tags` (optional) — Filter by tags (comma-separated)

**Response:**
```json
{
  "cats": [
    {
      "id": "uuid",
      "name": "Whiskers McFluff",
      "slug": "whiskers-mcfluff",
      "description": "A majestic...",
      "image_url": "https://...",
      "price": { "amount_cents": 9999, "currency": "USD" },
      "tags": ["fluffy", "dignified"]
    }
  ],
  "meta": { "page": 1, "per_page": 20, "total": 42 }
}
```

### `GET /api/catalog/:slug`

Returns full details of a single cat.

**Response:**
```json
{
  "id": "uuid",
  "name": "Whiskers McFluff",
  "slug": "whiskers-mcfluff",
  "description": "A majestic...",
  "image_url": "https://...",
  "price": { "amount_cents": 9999, "currency": "USD" },
  "profile": {
    "age_months": 24,
    "temperament": "Dignified observer",
    "traits": ["fluffy", "dignified", "mysterious"]
  },
  "media": [
    { "url": "https://...", "alt_text": "Whiskers lounging" }
  ]
}
```

---

## 2. Custom Cats (Authenticated User)

Manage user-specific AI-generated cats.

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/custom-cats` | List current user's custom cats | Yes |
| `GET` | `/api/custom-cats/:id` | Get details of a specific custom cat | Yes |
| `DELETE` | `/api/custom-cats/:id` | Archive a custom cat | Yes |

### `GET /api/custom-cats`

Returns all custom cats belonging to the authenticated user.

**Query Parameters:**
- `include_archived` (optional) — Include archived cats (default: `false`)

**Response:**
```json
{
  "custom_cats": [
    {
      "id": "uuid",
      "name": "Lord Fluffington III",
      "description": "An AI-generated...",
      "image_url": "https://...",
      "visibility": "private",
      "created_at": "2025-01-15T10:30:00Z"
    }
  ]
}
```

### `GET /api/custom-cats/:id`

Returns full details of a custom cat owned by the current user.

**Response:**
```json
{
  "id": "uuid",
  "name": "Lord Fluffington III",
  "description": "An AI-generated noble feline...",
  "image_url": "https://...",
  "visibility": "private",
  "prompt": {
    "text": "A regal cat with chaotic energy",
    "quiz_results": { "personality": "Chaotic Gremlin" }
  },
  "story": "Once upon a time in a cardboard castle...",
  "created_at": "2025-01-15T10:30:00Z"
}
```

**Error Responses:**
- `404 Not Found` — Cat does not exist or belongs to another user

### `DELETE /api/custom-cats/:id`

Archives a custom cat (soft delete). Returns `204 No Content` on success.

---

## 3. CatBot — AI Cat Generation (Authenticated User)

Generate custom cats using the AI-powered CatBot.

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `POST` | `/api/catbot/generate` | Generate a new custom cat from prompt | Yes |
| `POST` | `/api/catbot/regenerate-description` | Regenerate description for existing cat | Yes |
| `GET` | `/api/catbot/quiz` | Get quiz questions | No |
| `POST` | `/api/catbot/quiz/submit` | Submit quiz answers, get personality result | No |

### `POST /api/catbot/generate`

Generates a new custom cat based on user input and optional quiz results.

**Request:**
```json
{
  "prompt_text": "A fluffy orange cat with chaotic energy",
  "quiz_results": { "personality": "Chaotic Gremlin" },
  "selected_name": "Sir Fluffington"
}
```

**Response:**
```json
{
  "id": "uuid",
  "suggested_names": ["Sir Fluffington", "Chaos Paws", "Marmalade Menace"],
  "name": "Sir Fluffington",
  "description": "An orange ball of pure chaos...",
  "image_url": "https://...",
  "visibility": "private"
}
```

### `POST /api/catbot/regenerate-description`

Regenerates the description for an existing custom cat.

**Request:**
```json
{
  "custom_cat_id": "uuid",
  "modification_hint": "make it fluffier"
}
```

**Response:**
```json
{
  "id": "uuid",
  "description": "An impossibly fluffy...",
  "regenerated_at": "2025-01-15T11:00:00Z"
}
```

### `GET /api/catbot/quiz`

Returns the cat personality quiz questions.

**Response:**
```json
{
  "questions": [
    {
      "id": "q1",
      "text": "What's your ideal cat energy level?",
      "options": [
        { "value": "lazy", "label": "Lazy loaf" },
        { "value": "playful", "label": "Playful chaos agent" },
        { "value": "dignified", "label": "Dignified observer" },
        { "value": "zoomies", "label": "Zoomies at 3am" }
      ]
    }
  ]
}
```

### `POST /api/catbot/quiz/submit`

Submits quiz answers and returns a personality result to seed CatBot.

**Request:**
```json
{
  "answers": {
    "q1": "playful",
    "q2": "teleportation",
    "q3": "keyboard",
    "q4": "void"
  }
}
```

**Response:**
```json
{
  "personality": "Chaotic Gremlin",
  "description": "A mischievous void of pure chaos...",
  "shareable_text": "I got a Chaotic Gremlin cat! 🐱"
}
```

---

## 4. Admin — Cat Management System (Admin Only)

Manage premade cats and view/moderate custom cats.

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/admin/cats` | List all cats (premade & custom) | Admin |
| `POST` | `/api/admin/cats` | Create a new premade cat | Admin |
| `GET` | `/api/admin/cats/:id` | Get any cat by ID | Admin |
| `PUT` | `/api/admin/cats/:id` | Update a premade cat | Admin |
| `DELETE` | `/api/admin/cats/:id` | Archive/delete a cat | Admin |
| `PATCH` | `/api/admin/cats/:id/publish` | Publish a premade cat | Admin |
| `PATCH` | `/api/admin/cats/:id/archive` | Archive a premade cat | Admin |

### `GET /api/admin/cats`

Returns all cats with admin-level details.

**Query Parameters:**
- `type` (optional) — Filter: `premade`, `custom`
- `visibility` (optional) — Filter: `public`, `private`, `archived`
- `user_id` (optional) — Filter custom cats by owner

**Response:**
```json
{
  "cats": [
    {
      "id": "uuid",
      "name": "Whiskers",
      "type": "premade",
      "visibility": "public",
      "creator_user_id": null,
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-01-10T00:00:00Z"
    }
  ],
  "meta": { "page": 1, "total": 100 }
}
```

### `POST /api/admin/cats`

Creates a new premade cat listing.

**Request:**
```json
{
  "name": "Whiskers McFluff",
  "description": "A majestic...",
  "image_url": "https://...",
  "price_cents": 9999,
  "currency": "USD",
  "tags": ["fluffy", "dignified"],
  "slug": "whiskers-mcfluff"
}
```

**Response:** Returns the created cat with `201 Created`.

### `PUT /api/admin/cats/:id`

Updates a premade cat. Custom cats cannot be edited by admin.

**Request:**
```json
{
  "name": "Updated Name",
  "description": "Updated description...",
  "price_cents": 12999
}
```

### `PATCH /api/admin/cats/:id/publish`

Publishes a premade cat to the public catalog (sets visibility to `public`).

**Response:**
```json
{
  "id": "uuid",
  "visibility": "public",
  "published_at": "2025-01-15T12:00:00Z"
}
```

### `PATCH /api/admin/cats/:id/archive`

Archives a cat (sets visibility to `archived`). Removes from public catalog but remains in system.

**Response:**
```json
{
  "id": "uuid",
  "visibility": "archived",
  "archived_at": "2025-01-15T12:00:00Z"
}
```

---

## 5. Error Response Format

All endpoints return errors in a consistent format:

```json
{
  "error": {
    "code": "cat_not_found",
    "message": "The requested cat does not exist",
    "details": { "cat_id": "uuid" }
  }
}
```

**Common HTTP Status Codes:**
- `400 Bad Request` — Invalid request body or parameters
- `401 Unauthorized` — Authentication required
- `403 Forbidden` — Insufficient permissions (e.g., non-admin accessing admin endpoints)
- `404 Not Found` — Resource does not exist
- `422 Unprocessable Entity` — Validation errors
