# Cat-alog Authentication Spec (Rails API + Vercel Frontend)

## Scope
This document specifies authentication and session behavior for:
- **Shoppers** using the Vercel frontend and Rails API
- **Admins** using a Rails-hosted admin UI

This spec prioritizes **minimal custom code**, **browser-only clients**, and clear separation between shopper and admin authentication.

---

## Recommended Approach
### Summary
- Use **Devise** for both shoppers and admins to minimize custom auth code.
- Use **cookie-based sessions** managed by Rails (no SPA token storage).
- Shoppers authenticate via:
  - **Username/password registration + login** (Devise database auth)
  - **Sign in with Google** (Devise OmniAuth via `omniauth-google-oauth2`)
- Admins authenticate via:
  - **Username/password only**
  - **No self-registration**; admins created via server-side script.

### Rails as the authority
- Rails is the **system of record** for authentication + authorization.
- Vercel frontend relies on Rails session cookies by making API calls with credentials.

---

## Functional Requirements

### FR-1: Shopper account registration (username/password)
- Shoppers can create an account using:
  - username (or email; see FR-1a)
  - password
- Minimum password requirements must be enforced (see NFR-3).
- Registration must create a shopper principal in Rails.

#### FR-1a: Identity field choice
- Preferred: **email as primary identity** (Devise defaults; simplest)
- Optional enhancement: support separate `username` in addition to email.

### FR-2: Shopper sign-in (username/password)
- Shoppers can sign in from the Vercel app.
- Successful sign-in establishes a Rails session.

### FR-3: Shopper sign-in with Google
- Shoppers can sign in using Google as an IdP.
- If a shopper signs in with Google and does not yet exist, the system must:
  - Create a shopper account linked to the Google identity (`provider`, `uid`)
  - Store verified email and basic profile fields as needed.
- If a shopper exists with the same verified email, the system should:
  - Link the Google identity to the existing account (policy: allow if email verified and matches).

### FR-4: Shopper sign-out
- Shoppers can sign out from the Vercel app.
- Sign-out invalidates the Rails session.

### FR-5: Admin authentication (username/password)
- Admin UI lives in the Rails app (server-rendered or Rails-hosted pages).
- Admins authenticate with username/password.
- Admin authentication is independent from shopper authentication.

### FR-6: Admin provisioning via server-side script
- There must be a server-only mechanism to add admins.
- Supported mechanisms:
  - `rails runner` command
  - rake task
- Admin creation must not be available through public web endpoints.

### FR-7: Admin sign-out
- Admins can sign out from Rails admin UI.
- Sign-out invalidates the admin session.

### FR-8: Authorization boundaries
- Admin-only actions are accessible only to `AdminUser` sessions.
- Shopper-only resources are accessible only to `User/Shopper` sessions.
- Public resources remain accessible without authentication.

### FR-9: Session-based API access from Vercel
- Vercel frontend calls Rails API with cookies.
- Rails must expose endpoints for the frontend to determine current auth state:
  - `GET /session` (shopper) → returns logged-in status + minimal profile
  - `GET /admin/session` (admin) → returns logged-in status + role

### FR-10: Google OAuth callback handling
- OAuth callback is handled by Rails.
- After successful Google auth, Rails redirects the browser back to Vercel.
- Because OmniAuth uses CSRF protections, the OAuth start should be **POST-based** (see NFR-4).

---

## Non-Functional Requirements

### NFR-1: Browser-only security posture
- No support required for native/mobile/third-party API clients.
- Do **not** store long-lived auth tokens in localStorage/sessionStorage.

### NFR-2: Cookie/session security
Rails must set session cookies with:
- `HttpOnly: true`
- `Secure: true` (production)
- `SameSite: Lax` (to allow OAuth redirects to work reliably)
- Reasonable expiration / idle timeout (e.g., 30–60 minutes for admin; longer acceptable for shoppers)

### NFR-3: Password policy
- Enforce a minimum password length (e.g., 12 characters) and basic strength.
- Apply login rate limiting to mitigate brute force.
- Consider account lockout for admins.

### NFR-4: CSRF protection
- Rails must enforce CSRF protection for cookie-authenticated endpoints.
- OmniAuth start should be initiated with a POST (or equivalent safe mechanism) to satisfy CSRF expectations.
- If the Vercel frontend triggers OAuth, provide a Rails route that returns an auto-submitting POST form or another compliant pattern.

### NFR-5: CORS and credentials
If the browser calls Rails directly (no proxy), Rails must:
- Allowlist the Vercel origin(s)
- Set `Access-Control-Allow-Credentials: true`
- Avoid wildcard origins

If Vercel proxies `/api/*` to Rails, CORS complexity is reduced; this is acceptable.

### NFR-6: Domain strategy
Recommended deployment domains:
- `app.example.com` (Vercel)
- `api.example.com` (Rails)

This minimizes cookie + origin complexity.

### NFR-7: Minimal data exposure
- Session endpoints should return minimal necessary fields.
- Do not expose secrets, provider tokens, or sensitive PII.

### NFR-8: Auditing (admin)
- Record admin authentication events and privileged actions (at least: who/when/what).

---

## Implementation Notes (Devise-based)

### Models
- `User` (shopper)
  - Devise modules: database auth + registration + recovery + omniauthable
  - Columns: email, encrypted_password, provider, uid, etc.
- `AdminUser`
  - Devise modules: database auth (no registration)
  - Columns: username, encrypted_password

### Gems
- `devise`
- `omniauth-google-oauth2`
- `omniauth-rails_csrf_protection`

### Endpoint Sketch
Shopper:
- `POST /users` (register) or Devise registrations
- `POST /users/sign_in`
- `DELETE /users/sign_out`
- `POST /users/auth/google_oauth2` (OmniAuth start)
- `GET /users/auth/google_oauth2/callback`
- `GET /session`

Admin:
- `POST /admin_users/sign_in`
- `DELETE /admin_users/sign_out`
- `GET /admin/session`

### Admin provisioning script
Example pattern (production):
- `ADMIN_PASSWORD=... RAILS_ENV=production bin/rails runner 'AdminUser.create!(username: "alice", password: ENV.fetch("ADMIN_PASSWORD"))'`

---

## Out of Scope
- Multi-factor authentication for shoppers
- Order history accounts and profile management
- Non-browser clients / API token auth
- SSO beyond Google for shoppers

