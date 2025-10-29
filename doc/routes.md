# Application Routes

## Overview

This document outlines all the routes in the application. The core functionality is accessed via **WhatsApp** (conversational interface). Web routes are minimal and focused on registration, dashboard, and administration.

## Architecture Note

- **Primary Interface:** WhatsApp (via Unipile webhooks)
- **Secondary Interface:** Web (dashboard and admin only)
- **Authentication:** Devise for web, Unipile account_id for WhatsApp
- **Subscription Management:** Stripe Customer Portal (no custom subscription routes needed)

---

## Public Routes (Unauthenticated)

### Landing & Registration Journey

**User Journey:** Discovery → Registration → Payment → Success

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/` | Landing page with product info and CTA | 1. Discovery |
| GET | `/inscription` | Registration form (name, email, phone, company, SIRET, VAT, language) | 2. Sign Up |
| POST | `/inscription` | Process registration and redirect to Stripe Checkout | 3. Submit |
| GET | `/inscription/success` | Payment success page with WhatsApp connection instructions | 4. Success |
| GET | `/mentions-legales` | Legal notices | Reference |
| GET | `/cgu` | Terms and conditions | Reference |
| GET | `/politique-confidentialite` | Privacy policy | Reference |

**Note:** Stripe Checkout handles the payment page (no custom route needed).

---

## Authenticated Routes (Artisan/User)

### Authentication Journey

**User Journey:** Login → Dashboard / Password Reset → Email → Reset

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/connexion` | Sign in page | 1. Login Page |
| POST | `/connexion` | Process sign in | 2. Submit Login |
| DELETE | `/deconnexion` | Sign out | Exit |
| GET | `/mot-de-passe/oublie` | Forgot password form | 1. Forgot |
| POST | `/mot-de-passe/oublie` | Send password reset email | 2. Request Reset |
| GET | `/mot-de-passe/nouveau` | Reset password form (from email link) | 3. Reset Form |
| PATCH | `/mot-de-passe/nouveau` | Update password | 4. Save New Password |

### Dashboard Journey

**User Journey:** Login → Dashboard → Profile

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/dashboard` | Main dashboard with stats and recent activity | 1. Home |
| GET | `/profil` | User profile view and edit | 2. Profile View |
| PATCH | `/profil` | Update user profile | 3. Update Profile |

### WhatsApp Connection Journey

**User Journey:** Dashboard → Connect WhatsApp → Scan QR → Connected

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/whatsapp/connexion` | WhatsApp connection page with QR code | 1. Connection Page |
| POST | `/whatsapp/connexion` | Request QR code from Unipile | 2. Generate QR |
| GET | `/whatsapp/statut` | Check connection status (AJAX polling) | 3. Verify Connection |
| DELETE | `/whatsapp/deconnexion` | Disconnect WhatsApp account | Disconnect |

### Client Management Journey

**User Journey:** Dashboard → Clients List → View Client / Create → Save → View Details

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/clients` | List all clients with search and filters | 1. Clients List |
| GET | `/clients/:id` | View client details with quotes/invoices history | 2. Client Details |
| GET | `/clients/nouveau` | Create client form (web interface) | 1. New Client Form |
| POST | `/clients` | Save new client (web interface) | 2. Save Client |
| GET | `/clients/:id/modifier` | Edit client form | 1. Edit Form |
| PATCH | `/clients/:id` | Update client | 2. Save Changes |
| DELETE | `/clients/:id` | Delete client (soft delete) | Delete |

**Note:** Clients are primarily created via WhatsApp conversation.

### Quote Management Journey

**User Journey:** Dashboard → Quotes List → View Quote → Download/Resend PDF

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/devis` | List all quotes with filters (status, date, client) | 1. Quotes List |
| GET | `/devis/:id` | View quote details with items and PDF | 2. Quote Details |
| GET | `/devis/:id/pdf` | Download quote PDF | 3. Download |
| GET | `/devis/:id/apercu` | Preview quote before sending | 3. Preview |
| POST | `/devis/:id/envoyer-whatsapp` | Resend quote PDF via WhatsApp | 4. Resend |

**Note:** Quotes are primarily created via WhatsApp conversation. Web interface is read-only + resend capability.

### Invoice Management Journey

**User Journey:** Dashboard → Invoices List → View Invoice → Manage Status / Download/Resend PDF

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/factures` | List all invoices with filters (status, date, client) | 1. Invoices List |
| GET | `/factures/:id` | View invoice details with items and PDF | 2. Invoice Details |
| GET | `/factures/:id/pdf` | Download invoice PDF | 3. Download |
| GET | `/factures/:id/apercu` | Preview invoice before sending | 3. Preview |
| POST | `/factures/:id/envoyer-whatsapp` | Resend invoice PDF via WhatsApp | 4. Resend |
| PATCH | `/factures/:id/statut` | Update invoice status (paid, overdue) | 5. Update Status |

**Note:** Invoices are primarily created via WhatsApp conversation. Web interface is read-only + status management.

### Subscription Management Journey (Stripe Customer Portal)

**User Journey:** Dashboard → Click "Manage Subscription" → Stripe Portal (external)

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| POST | `/abonnement/portail` | Create Stripe Customer Portal session and redirect | 1. Open Portal |

**What Stripe Customer Portal Handles:**
- ✅ View subscription details and status
- ✅ View and download all subscription invoices
- ✅ Update payment method
- ✅ Cancel subscription (at period end)
- ✅ Reactivate canceled subscription
- ✅ Update billing information
- ✅ View payment history

**Return URL:** After managing subscription in Stripe Portal, user returns to `/dashboard`

**Benefits:**
- Zero custom UI to maintain
- PCI compliance handled by Stripe
- Automatic updates when Stripe adds features
- Localized in user's language
- Mobile-responsive by default

### Conversation History Journey

**User Journey:** Dashboard → Conversations → View Conversation Messages

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/conversations` | List WhatsApp conversation history | 1. History List |
| GET | `/conversations/:id` | View conversation details with messages | 2. Conversation Details |

**Note:** Read-only. Conversations happen on WhatsApp in real-time.

---

## Admin Routes

**Namespace:** `/admin`

**Authentication:** Admin-only access (role-based)

### Admin Dashboard Journey

**User Journey:** Admin Login → Admin Dashboard → Analytics

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin` | Admin dashboard with global stats and metrics | 1. Admin Home |
| GET | `/admin/metriques` | Detailed metrics and analytics | 2. Analytics |

### User Management Journey

**User Journey:** Admin → Users List → View User → Manage Account / View Logs

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin/utilisateurs` | List all users with search and filters | 1. Users List |
| GET | `/admin/utilisateurs/:id` | View user details and activity | 2. User Details |
| GET | `/admin/utilisateurs/:id/modifier` | Edit user form | 3. Edit Form |
| PATCH | `/admin/utilisateurs/:id` | Update user | 4. Save Changes |
| POST | `/admin/utilisateurs/:id/suspendre` | Suspend user account | Action: Suspend |
| POST | `/admin/utilisateurs/:id/activer` | Activate suspended account | Action: Activate |
| POST | `/admin/utilisateurs/:id/reset-whatsapp` | Force WhatsApp reconnection | Action: Reset WhatsApp |
| GET | `/admin/utilisateurs/:id/logs` | View user activity logs | View Logs |
| POST | `/admin/utilisateurs/:id/portail-stripe` | Create Stripe Portal session for user (admin access) | Stripe Portal |

### Subscription Management Journey

**User Journey:** Admin → Subscriptions List → View Subscription Details

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin/abonnements` | List all subscriptions with filters (status, Stripe ID) | 1. Subscriptions List |
| GET | `/admin/abonnements/:id` | View subscription details (links to Stripe Dashboard) | 2. Subscription Details |
| GET | `/admin/abonnements/impayes` | List overdue subscriptions | View Overdue |

**Note:** Admin manages subscriptions in Stripe Dashboard (no manual suspend/reactivate routes). Webhooks handle all status updates automatically.

### System Monitoring Journey

**User Journey:** Admin → Logs → View Details / Webhooks → Replay Failed

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin/logs` | System logs with filters (type, date, user) | 1. Logs List |
| GET | `/admin/logs/:id` | View detailed log entry | 2. Log Details |
| GET | `/admin/webhooks` | Webhook activity log (Unipile, Stripe) | 1. Webhooks Log |
| POST | `/admin/webhooks/:id/rejouer` | Replay failed webhook | Action: Replay |

### Settings Management Journey

**User Journey:** Admin → Settings → Configure Services / Test Connections

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin/parametres` | Global application settings | 1. Settings Home |
| PATCH | `/admin/parametres` | Update settings | 2. Save Settings |
| GET | `/admin/parametres/unipile` | Unipile configuration and status | View Unipile Config |
| POST | `/admin/parametres/unipile/test` | Test Unipile connection | Test Connection |
| GET | `/admin/parametres/stripe` | Stripe configuration | View Stripe Config |
| GET | `/admin/parametres/openai` | OpenAI configuration | View OpenAI Config |

---

## Webhook Routes (API)

**Authentication:** Signature verification or API token

### Unipile Webhooks (Real-time Message Processing)

**Journey:** Unipile Event → Our Webhook → Process Message → AI Response → Send Reply

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| POST | `/webhooks/unipile/messages` | Receive WhatsApp message events from Unipile | 1. Receive Message |
| POST | `/webhooks/unipile/accounts` | Receive account status updates (connected, disconnected) | Account Updates |

**Payload:** See Unipile webhook documentation

**Processing:**
- Upsert WhatsappChat and WhatsappMessage
- Detect conversation context
- Process through AI workflow
- Send response via Unipile API

### Stripe Webhooks (Payment Processing)

**Journey:** Stripe Event → Our Webhook → Update Account Status → Notify User

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| POST | `/webhooks/stripe` | Handle Stripe events (payment success/failure) | Process Payment Event |

**Events Handled:**
- `checkout.session.completed` → Activate account after first payment
- `invoice.payment_succeeded` → Maintain active status
- `invoice.payment_failed` → Suspend account, send notification
- `customer.subscription.created` → Create subscription record
- `customer.subscription.updated` → Update subscription status
- `customer.subscription.deleted` → Mark subscription as canceled
- `invoice.finalized` → Store subscription invoice details

---

## API Routes (Internal/Future)

**Namespace:** `/api/v1`

**Authentication:** API token (for future integrations)

**Note:** These routes are for future use, not in initial MVP.

### Status & Health Checks

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/api/v1/statut` | Application health check | Health Check |
| GET | `/api/v1/statut/whatsapp` | WhatsApp connection status for current user | WhatsApp Status |
| GET | `/api/v1/messages/nouveaux` | Poll for new messages (if webhooks fail) | Polling Fallback |

---

## Route Count Summary

| Category | Route Count | Interface | Primary Journey |
|----------|-------------|-----------|-----------------|
| **Public (Registration)** | 7 | Web | Discovery → Payment → Success |
| **Authentication** | 7 | Web | Login → Dashboard |
| **User Dashboard** | 3 | Web | Home → Profile |
| **WhatsApp Connection** | 4 | Web | Connect → Scan QR → Verify |
| **Clients** | 7 | Web | List → View → Manage |
| **Quotes** | 5 | Web | List → View → Download/Resend |
| **Invoices** | 6 | Web | List → View → Manage Status |
| **Subscription** | 1 | Stripe Portal | Managed by Stripe |
| **Conversations** | 2 | Web | View History |
| **Admin - Dashboard** | 2 | Web | Admin Home → Analytics |
| **Admin - Users** | 9 | Web | List → View → Manage |
| **Admin - Subscriptions** | 3 | Web | List → View (in Stripe) |
| **Admin - Monitoring** | 4 | Web | Logs → Webhooks |
| **Admin - Settings** | 6 | Web | Configure → Test |
| **Webhooks** | 3 | API | Receive → Process → Respond |
| **API (Future)** | 3 | API | Health Checks |
| **TOTAL** | **72 routes** | | |

**Routes Eliminated:** 6 subscription management routes replaced by 1 Stripe Portal redirect

---

## WhatsApp Commands (Conversational Interface)

**Primary user interface via WhatsApp messages**

These are not HTTP routes but conversational triggers:

### Document Creation Journey

**Journey:** Send Command → AI Guides Through Steps → Confirm → PDF Generated → PDF Sent

| Command (FR) | Command (TR) | Action | Journey |
|--------------|--------------|--------|---------|
| "créer un devis" / "nouveau devis" | "teklif oluştur" / "yeni teklif" | Start quote creation workflow | Create Quote |
| "créer une facture" / "nouvelle facture" | "fatura oluştur" / "yeni fatura" | Start invoice creation workflow | Create Invoice |
| "créer un client" / "nouveau client" | "müşteri oluştur" / "yeni müşteri" | Start client creation workflow | Create Client |

### Information Query Journey

**Journey:** Send Command → Receive Formatted List → Ask for Details → View Item

| Command (FR) | Command (TR) | Action | Journey |
|--------------|--------------|--------|---------|
| "mes clients" / "liste clients" | "müşterilerim" / "müşteri listesi" | Show client list | View Clients |
| "mes devis" / "liste devis" | "tekliflerim" / "teklif listesi" | Show recent quotes | View Quotes |
| "mes factures" / "liste factures" | "faturalarım" / "fatura listesi" | Show recent invoices | View Invoices |
| "aide" / "help" / "?" | "yardım" | Show help menu | Get Help |

### Workflow Control Journey

**Journey:** Issue Command → Workflow Responds → Return to Previous State

| Command (FR) | Command (TR) | Action | Journey |
|--------------|--------------|--------|---------|
| "annuler" / "stop" | "iptal" / "dur" | Cancel current workflow | Cancel |
| "recommencer" / "restart" | "yeniden başla" | Restart current workflow | Restart |
| "précédent" / "retour" | "geri" / "önceki" | Go back to previous step | Go Back |

**Language Support:** All commands work in French and Turkish based on user's preferred language setting.

---

## User Journey Flows (End-to-End)

### 1. New User Onboarding Journey

```
Landing (/) 
  → Registration (/inscription) 
  → Stripe Checkout (external)
  → Success (/inscription/success)
  → Login (/connexion)
  → Dashboard (/dashboard)
  → WhatsApp Connection (/whatsapp/connexion)
  → Scan QR Code
  → Connected! (Poll /whatsapp/statut)
  → Start creating documents via WhatsApp
```

### 2. Create Quote via WhatsApp Journey

```
WhatsApp: "créer un devis"
  → AI: "Pour quel client?"
  → User: "Entreprise Dubois"
  → AI: "Client trouvé. Première prestation?"
  → User: "Maçonnerie mur extérieur, 50m², 85€/m²"
  → AI: "Confirmé. Autre prestation?"
  → User: "non"
  → AI: "Total HT: 4250€, TVA: 850€, TTC: 5100€. Valider?"
  → User: "oui"
  → AI: Generates PDF
  → AI: Sends PDF on WhatsApp
  → User can view on web (/devis) later
```

### 3. View and Resend Quote Journey

```
Dashboard (/dashboard)
  → Quotes List (/devis)
  → Select Quote (/devis/:id)
  → View Details + PDF
  → Click "Resend via WhatsApp"
  → POST /devis/:id/envoyer-whatsapp
  → Success message
  → PDF sent to client on WhatsApp
```

### 4. Manage Subscription Journey (Stripe Portal)

```
Dashboard (/dashboard)
  → Click "Manage Subscription" button
  → POST /abonnement/portail
  → Create Stripe Customer Portal session
  → Redirect to Stripe Portal (external)
  → User manages subscription (update payment, view invoices, cancel)
  → Returns to /dashboard
  → Webhooks update local subscription data
```

### 5. Admin User Management Journey

```
Admin Login (/connexion)
  → Admin Dashboard (/admin)
  → Users List (/admin/utilisateurs)
  → Search User
  → View User (/admin/utilisateurs/:id)
  → Check Activity Logs (/admin/utilisateurs/:id/logs)
  → Suspend Account (POST /admin/utilisateurs/:id/suspendre)
  → User notified via email
```

### 6. Payment Failure Recovery Journey

```
Stripe webhook: invoice.payment_failed
  → POST /webhooks/stripe
  → Update subscription status to 'past_due'
  → Email sent to user with Stripe Portal link
  → User clicks link in email
  → Stripe Portal opens (external)
  → User updates payment method
  → Stripe retries payment
  → Stripe webhook: invoice.payment_succeeded
  → POST /webhooks/stripe
  → Account reactivated automatically
```

---

## Stripe Integration Details

### Stripe Checkout (Registration)

**Flow:**
1. User submits registration form → `POST /inscription`
2. Create Stripe Checkout Session with:
   - Price ID (monthly subscription)
   - Customer email
   - Success URL: `/inscription/success`
   - Cancel URL: `/inscription`
3. Redirect user to Stripe Checkout (external)
4. User completes payment
5. Stripe webhook: `checkout.session.completed`
6. Activate user account
7. User returns to `/inscription/success`

**Stripe Checkout Session Parameters:**
```ruby
Stripe::Checkout::Session.create(
  mode: 'subscription',
  line_items: [{
    price: ENV['STRIPE_PRICE_ID'],
    quantity: 1
  }],
  customer_email: user.email,
  client_reference_id: user.id,
  success_url: "#{root_url}inscription/success?session_id={CHECKOUT_SESSION_ID}",
  cancel_url: "#{root_url}inscription",
  metadata: {
    user_id: user.id
  }
)
```

### Stripe Customer Portal (Subscription Management)

**Flow:**
1. User clicks "Manage Subscription" → `POST /abonnement/portail`
2. Create Stripe Customer Portal Session:
   ```ruby
   Stripe::BillingPortal::Session.create(
     customer: current_user.stripe_customer_id,
     return_url: dashboard_url
   )
   ```
3. Redirect to Stripe Portal URL
4. User manages subscription (Stripe handles everything)
5. User clicks "Return to app" → back to `/dashboard`
6. Changes synced via webhooks

**What Users Can Do in Portal:**
- View subscription details
- Update payment method
- Cancel subscription
- Reactivate subscription
- View invoice history
- Download invoices
- Update billing address

### Stripe Webhook Events

**Critical Events:**
```ruby
case event.type
when 'checkout.session.completed'
  # First payment successful → activate account
when 'invoice.payment_succeeded'
  # Recurring payment successful → ensure active status
when 'invoice.payment_failed'
  # Payment failed → suspend account, email user
when 'customer.subscription.updated'
  # Subscription changed → update status (canceled, active, etc.)
when 'customer.subscription.deleted'
  # Subscription ended → mark as canceled
when 'invoice.finalized'
  # Invoice created → store for records
end
```

---

## Route Naming Conventions

### Path Structure
- **French paths** for user-facing routes: `/devis`, `/factures`, `/clients`
- **English paths** for admin/API routes: `/admin/users`, `/api/v1/messages`
- Resource names in **singular** for show: `/devis/:id`
- Resource names in **plural** for index: `/devis`
- Journey-aware grouping: Related actions use same base path

### Controller Actions
- `index` → List resources (Journey: 1. List)
- `show` → Display single resource (Journey: 2. View Details)
- `new` → Show creation form (Journey: 1. New Form)
- `create` → Process creation (Journey: 2. Save)
- `edit` → Show edit form (Journey: 1. Edit Form)
- `update` → Process update (Journey: 2. Save Changes)
- `destroy` → Delete resource (Journey: Delete)

### Custom Actions
- Use **POST** for state changes: `POST /devis/:id/envoyer-whatsapp`
- Use descriptive names in **French** for user routes
- Use descriptive names in **English** for admin routes
- Action verbs: `envoyer`, `suspendre`, `activer`, `rejouer`, `portail`

---

## Security & Access Control

### Authentication Levels

1. **Public:** Landing, registration, legal pages
2. **Authenticated User:** Dashboard, clients, quotes, invoices, Stripe Portal
3. **Admin:** Full admin namespace + Stripe Dashboard access
4. **API (Webhooks):** Signature verification for Unipile/Stripe

### Authorization Rules

- Users can only access **their own** data (clients, quotes, invoices, conversations)
- Admins can access **all** data with audit logging
- WhatsApp messages linked to user via `unipile_account_id`
- Webhook endpoints verify sender authenticity (Stripe signature, Unipile token)
- Stripe Portal sessions are scoped to user's Stripe customer ID

### Rate Limiting

- **Public routes:** 100 requests/hour per IP (registration journey)
- **Authenticated routes:** 1000 requests/hour per user (dashboard journey)
- **Webhook routes:** No limit (trusted sources with signature verification)
- **API routes:** 5000 requests/hour per token (future)

---

## Error Pages

| Code | Path | Description | User Journey Action |
|------|------|-------------|---------------------|
| 404 | `/404` | Page not found | Redirect to dashboard or show helpful links |
| 500 | `/500` | Internal server error | Show error with support contact |
| 403 | `/403` | Access forbidden | Redirect to login or show permission error |
| 422 | `/422` | Unprocessable entity | Show form errors inline |

---

## Redirects & Journey Shortcuts

| From | To | Condition | Journey Context |
|------|----|-----------|-----------------
| `/` | `/` (landing) | Unauthenticated | Start journey |
| `/` | `/dashboard` | Authenticated | Continue journey |
| `/admin` | `/admin/dashboard` | Admin | Admin home |
| `/devis/nouveau` | N/A | Always | Redirect to WhatsApp with instructions |
| `/factures/nouveau` | N/A | Always | Redirect to WhatsApp with instructions |
| `/abonnement` | `/abonnement/portail` | Always | Direct to Stripe Portal (auto-redirect) |

---

## Development Routes

**Only in development/staging environment**

| Method | Path | Description | Journey |
|--------|------|-------------|---------|
| GET | `/dev/emails` | Email preview (LetterOpener) | Debug emails |
| GET | `/dev/sidekiq` | Sidekiq web UI for job monitoring | Debug jobs |
| GET | `/dev/webhooks` | Webhook testing tool | Test webhooks |
| GET | `/dev/stripe` | Stripe event simulator | Test Stripe webhooks |

---

## Notes

### Why So Few Routes?

1. **WhatsApp-First Architecture:** Most interactions happen via WhatsApp conversational interface
2. **Read-Only Web Dashboard:** Users primarily **view** data on web, **create** via WhatsApp
3. **Stripe Customer Portal:** No need for 6+ subscription management routes
4. **Journey-Focused Design:** Each route serves a specific step in a user journey
5. **Admin Efficiency:** Admin routes are utilitarian, not customer-facing
6. **Webhooks Handle Complexity:** Real-time message processing happens server-side via webhooks

### Benefits of Stripe Customer Portal

1. **Zero maintenance:** Stripe updates features automatically
2. **PCI compliance:** No sensitive payment data touches our servers
3. **Localization:** Automatic translation to user's language
4. **Mobile-optimized:** Responsive design out of the box
5. **Security:** Stripe handles all payment security
6. **Invoice management:** Built-in invoice viewing and downloading
7. **Legal compliance:** Stripe handles SCA, 3D Secure, etc.

### Journey-First Design Principles

- **Clear Entry Points:** Each major feature has a clear starting route
- **Logical Progression:** Routes follow natural user mental models
- **Exit Strategies:** Every journey has a way back (breadcrumbs, cancel buttons)
- **Mobile-First:** WhatsApp journeys are mobile-native, web is desktop-optimized
- **State Management:** Journeys maintain context across multiple steps
- **External Services:** Leverage Stripe Portal for complex subscription management

### Future Considerations

- Mobile app routes (if native app is built later)
- Advanced analytics routes for power users
- Export/import routes for accounting integration
- Multi-language route alternatives (Turkish paths: `/teklifler`, `/faturalar`)
- API routes for third-party integrations (accounting software, CRM)
- Stripe Connect (if enabling payments to artisans' accounts)
