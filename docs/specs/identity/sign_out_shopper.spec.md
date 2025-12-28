# SignOutShopper — Capability Spec

**Bounded Context:** Identity & Profile
**Status:** planned
**Generated:** 2025-12-28T03:09:05.692Z
**Source:** `/Users/pcaplan/paul/cats-as-a-service/architecture/identity.json`

<!-- 
Status values:
  - template: Initial generated template, not yet planned
  - planned: Specs completed via /rampart.plan, ready for implementation
  - implemented: Code implementation complete
Update this status as you progress through the workflow.
-->

---

## Overview

Invalidate the shopper's current session

**Actors:** Shopper
**Entrypoints:** ShopperSessionsController#destroy
**Outputs:** N/A

---

## Acceptance Criteria

<!-- Use EARS notation for testable requirements -->

### Happy Path

- [ ] WHEN an authenticated shopper requests sign-out THE SYSTEM SHALL invalidate the current session
- [ ] WHEN sign-out succeeds THE SYSTEM SHALL clear the session cookie
- [ ] WHEN sign-out succeeds THE SYSTEM SHALL return HTTP 200 with confirmation

### Idempotency

- [ ] WHEN an unauthenticated guest requests sign-out THE SYSTEM SHALL return HTTP 200 (no-op, idempotent)

---

## Error Handling

<!-- Define error scenarios using EARS IF/THEN notation -->

*Sign-out is inherently safe and idempotent. No error scenarios.*

---

## Domain State & Data

### Aggregates involved

**Aggregate:** ShopperIdentity (read-only for session validation)

*Sign-out does not modify aggregate state — it only destroys the session.*

---

## Data Model

<!-- Map the Aggregate attributes above to a persistence schema -->
<!-- Note: Only model tables owned by this Bounded Context -->

*No schema changes required. Session is stored in cookies (Devise default) or Rails session store.*

---

## Request/Response Contracts

<!-- Define API payloads and Event DTOs -->

### Entrypoint

**DELETE /users/sign_out**

### Request

No request body required. Session cookie identifies the user.

```
DELETE /users/sign_out
Cookie: _session_id=...
```

### Success Response

**HTTP 200 OK**

```json
{
  "message": "Signed out successfully"
}
```

*Note: Session cookie is cleared (set to expired).*

### Alternative: No-Op Response

**HTTP 200 OK** (when already signed out)

```json
{
  "message": "Signed out successfully"
}
```

*Idempotent — same response whether session existed or not.*

---

## Architecture

### Capability Flow Diagram

```mermaid
flowchart TB
    Shopper["Shopper"]
    Shopper -->|"DELETE /users/sign_out"| Controller
    Controller["ShopperSessionsController#destroy"]
    Controller -->|invokes| Service
    Service["ShopperAuthService"]
    Service -->|"invalidate session"| Session[("Session Store")]
```

### Application Layer

**Services:**
- ShopperAuthService

### Domain Layer

**Aggregate:** ShopperIdentity (not modified)

### Infrastructure Layer

**Ports Used:**
- None (session management is framework-level)

---

## Implementation Notes

### Devise Configuration

Sign-out is handled entirely by Devise's `SessionsController#destroy`:

```ruby
# ShopperSessionsController
class ShopperSessionsController < Devise::SessionsController
  def destroy
    super do
      # Return JSON instead of redirect for API clients
      return render json: { message: "Signed out successfully" }
    end
  end
end
```

### Session Storage

- Default: Cookie-based session (Devise default)
- Session is invalidated by clearing/expiring the cookie
- No server-side session store required for MVP

### CSRF Protection

- Ensure `DELETE /users/sign_out` validates CSRF token for browser requests
- For API clients using bearer tokens (future), CSRF is not required

### Hexagonal Mapping

| Rampart Layer | Implementation |
|---------------|----------------|
| Controller | `ShopperSessionsController#destroy` (inherits Devise) |
| Service | `ShopperAuthService` (thin wrapper, delegates to Devise) |

### Keeping It Simple

Since we're leaning on Devise:
- `Devise::SessionsController#destroy` handles session invalidation
- Override only needed to return JSON instead of redirect
- No domain logic involved — purely infrastructure concern

---

## ✅ Post-Implementation Checklist

Once implementation is complete:

- [ ] All acceptance criteria pass
- [ ] Error handling scenarios covered by tests
- [ ] Update **Status** field at top of this file from `planned` to `implemented`
