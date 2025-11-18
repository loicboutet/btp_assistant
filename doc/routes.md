# Application Routes - Bot-First Architecture

## Overview

This application is **primarily a WhatsApp bot**. Users interact via WhatsApp and access the web through **magic links** (no passwords). The web interface is minimal and read-only.

## Architecture Principles

- **No registration form** - Users auto-created on first WhatsApp message
- **No passwords** - Authentication via secure magic links sent on WhatsApp
- **WhatsApp is primary** - Web is secondary (viewing/downloading only)
- **Ultra-minimal routes** - Only essential endpoints

---

## Public Routes (No Authentication)

### Magic Link Entry Point

**User Journey:** Receives Link on WhatsApp → Clicks → Auto-Logged In → Dashboard

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/u/:token` | Magic link authentication endpoint | Auto-Login |
| GET | `/` | Landing page (info/SEO only) | Discovery |
| GET | `/legal` | Legal notices | Reference |
| GET | `/terms` | Terms and conditions | Reference |
| GET | `/privacy` | Privacy policy | Reference |

**Magic Link Flow:**
```
1. User clicks: https://app.com/u/ABC123XYZ456...
2. System validates token
3. Creates session automatically
4. Redirects to /dashboard
5. User is logged in (no password needed)
```

---

## Authenticated Routes (After Magic Link)

**Note:** User accesses these routes AFTER clicking magic link from WhatsApp. No password required.

### Dashboard Journey

**User Journey:** Click Magic Link → Dashboard Home

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/dashboard` | Simple home with 4 cards: Quotes, Invoices, Clients, Profile | Home |
| DELETE | `/logout` | Clear session (rarely used) | Logout |

### Quote Management Journey

**User Journey:** Dashboard → Quotes → View Details → Download/Resend PDF

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/quotes` | Simple list with basic search (client, month filters) | 1. List |
| GET | `/quotes/:id` | View quote details and PDF preview | 2. View Details |
| GET | `/quotes/:id/pdf` | Download PDF file | 3. Download |
| POST | `/quotes/:id/send_whatsapp` | Resend PDF via WhatsApp | 4. Resend |

**Note:** Quotes are **created via WhatsApp only**. Web is read-only + resend.

### Invoice Management Journey

**User Journey:** Dashboard → Invoices → View Details → Manage Status

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/invoices` | Simple list with basic search (client, month filters) | 1. List |
| GET | `/invoices/:id` | View invoice details and PDF preview | 2. View Details |
| GET | `/invoices/:id/pdf` | Download PDF file | 3. Download |
| POST | `/invoices/:id/send_whatsapp` | Resend PDF via WhatsApp | 4. Resend |
| PATCH | `/invoices/:id/status` | Mark as paid/unpaid | 5. Update Status |

**Note:** Invoices are **created via WhatsApp only**. Web allows status updates.

### Client Management Journey

**User Journey:** Dashboard → Clients → View Client Details

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/clients` | Simple list with search | 1. List |
| GET | `/clients/:id` | View client with quotes/invoices history | 2. View Details |

**Note:** Clients are **created via WhatsApp only**. Web is view-only.

### Conversation History Journey

**User Journey:** Dashboard → Conversations → View Messages

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/conversations` | WhatsApp conversation history (read-only) | 1. History |
| GET | `/conversations/:id` | View conversation messages | 2. View Details |

### Profile & Subscription Journey

**User Journey:** Dashboard → Profile / Manage Subscription via Stripe

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/profile` | View profile info + request new magic link | Profile View |
| POST | `/profile/magic_link` | Request new magic link via WhatsApp | Regenerate Link |
| POST | `/subscription/portal` | Redirect to Stripe Customer Portal | Stripe Portal |

---

## Admin Routes

**Namespace:** `/admin`

**Authentication:** Admin password (traditional auth for admins only)

### Admin Dashboard Journey

**User Journey:** Admin Login → Dashboard → Manage Users

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin` | Admin dashboard with stats | 1. Admin Home |
| GET | `/admin/metrics` | System metrics and analytics | 2. Analytics |

### User Management Journey

**User Journey:** Admin → Users List → View User by Phone → Manage

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin/users` | List all users (search by phone, company, SIRET) | 1. Users List |
| GET | `/admin/users/:id` | View user details (phone, activity, magic link status) | 2. User Details |
| GET | `/admin/users/:id/edit` | Edit user info | 3. Edit Form |
| PATCH | `/admin/users/:id` | Update user | 4. Save |
| POST | `/admin/users/:id/suspend` | Suspend account | Action: Suspend |
| POST | `/admin/users/:id/activate` | Activate account | Action: Activate |
| POST | `/admin/users/:id/regenerate_magic_link` | Generate new magic link and send via WhatsApp | Action: New Link |
| GET | `/admin/users/:id/logs` | View user activity logs | View Logs |
| POST | `/admin/users/:id/stripe_portal` | Open Stripe portal for this user | Stripe Access |

**Key Admin Feature:** Search users by phone number (primary identifier)

### Subscription Management Journey

**User Journey:** Admin → Subscriptions → View in Stripe

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin/subscriptions` | List all subscriptions with filters | 1. List |
| GET | `/admin/subscriptions/:id` | View details (links to Stripe) | 2. View |
| GET | `/admin/subscriptions/overdue` | Overdue subscriptions | View Overdue |

### System Monitoring Journey

**User Journey:** Admin → Logs/Webhooks → Debug Issues

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin/logs` | System logs (filter by user phone, event) | 1. Logs |
| GET | `/admin/logs/:id` | Detailed log entry | 2. Details |
| GET | `/admin/webhooks` | Webhook activity (Unipile, Stripe) | 1. Webhooks |
| POST | `/admin/webhooks/:id/replay` | Replay failed webhook | Action: Replay |

### Settings Journey

**User Journey:** Admin → Settings → Configure APIs

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin/settings` | Application settings | 1. Settings |
| PATCH | `/admin/settings` | Update settings | 2. Save |
| GET | `/admin/settings/unipile` | Unipile config (API key, webhook) | Unipile |
| POST | `/admin/settings/unipile/test` | Test Unipile connection | Test |
| GET | `/admin/settings/stripe` | Stripe config | Stripe |
| GET | `/admin/settings/openai` | OpenAI config | OpenAI |

---

## Webhook Routes (API)

### Unipile Webhooks

**Journey:** WhatsApp Message → Webhook → Auto-Create User → Process → Respond

| Method | Path | Description | Processing |
|--------|------|-------------|------------|
| POST | `/webhooks/unipile/messages` | Receive WhatsApp messages + auto-create users | Main webhook |
| POST | `/webhooks/unipile/accounts` | Account status updates | Status sync |

**Key Processing:**
1. Extract phone number from `sender.attendee_provider_id`
2. Find or create User by phone number
3. Store WhatsappMessage
4. Detect conversation context
5. Process via AI/workflow
6. Send response via Unipile

### Stripe Webhooks

**Journey:** Payment Event → Webhook → Update Subscription → Notify User

| Method | Path | Description | Processing |
|--------|------|-------------|------------|
| POST | `/webhooks/stripe` | Handle all Stripe events | Payment processing |

**Events Handled:**
- `checkout.session.completed` → Activate subscription
- `invoice.payment_succeeded` → Keep active
- `invoice.payment_failed` → Suspend + WhatsApp notification
- `customer.subscription.updated` → Sync status
- `customer.subscription.deleted` → Mark canceled

---

## Route Count Summary

| Category | Route Count | Interface | Primary Journey |
|----------|-------------|-----------|-----------------|
| **Public** | 5 | Web | Magic Link Entry |
| **User Dashboard** | 2 | Web | View Data |
| **Quotes** | 4 | Web | List → View → Download |
| **Invoices** | 5 | Web | List → View → Manage |
| **Clients** | 2 | Web | List → View |
| **Conversations** | 2 | Web | View History |
| **Profile** | 2 | Web | View → Request Link |
| **Subscription** | 1 | Stripe Portal | External |
| **Admin** | 21 | Web | Full Management |
| **Webhooks** | 3 | API | Auto-processing |
| **TOTAL** | **47 routes** | | |

**Comparison:**
- Original plan: 72 routes
- Bot-first: **47 routes** (35% reduction!)

---

## WhatsApp Commands (Primary Interface)

Users primarily interact via WhatsApp. These commands trigger bot workflows:

### Core Commands

| Command (FR) | Command (TR) | Action | Journey |
|--------------|--------------|--------|---------|
| (any message from new number) | - | Auto-create user + start onboarding | First Contact |
| "créer un devis" | "teklif oluştur" | Start quote creation | Create Quote |
| "créer une facture" | "fatura oluştur" | Start invoice creation | Create Invoice |
| "nouveau client" | "yeni müşteri" | Start client creation | Create Client |
| "mes devis" | "tekliflerim" | List recent quotes | View Quotes |
| "mes factures" | "faturalarım" | List recent invoices | View Invoices |
| "mes clients" | "müşterilerim" | List clients | View Clients |
| "lien" / "web" / "accès" | "bağlantı" / "web" | Get/regenerate magic link | Get Web Access |
| "aide" / "help" | "yardım" | Show help menu | Help |
| "annuler" | "iptal" | Cancel current workflow | Cancel |

---

## Complete User Journeys

### Journey 1: New User (First Contact)

```
1. User sends WhatsApp: "Bonjour"
   → To: +33 6 12 00 00 00 (business number)

2. Webhook receives message
   → POST /webhooks/unipile/messages
   → Extract phone: +33612345678
   → User auto-created in database
   
3. Bot responds:
   → "Bienvenue ! 👋
      
      Je suis votre assistant pour créer devis et factures.
      
      Pour commencer, quel est le nom de votre entreprise ?"

4. User: "Maçonnerie Dubois"

5. Bot: "Parfait ! Et votre numéro SIRET ?"

6. User: "12345678901234"

7. Bot: "Merci ! Quel est votre adresse ?"

8. User: "15 rue de la Paix, 75001 Paris"

9. Bot: "✅ Votre compte est créé !
   
   📱 Accédez à votre espace web:
   https://app.com/u/ABC123XYZ456...
   
   Ce lien est personnel et sécurisé (valide 90 jours).
   
   Vous pouvez maintenant:
   • 'créer un devis'
   • 'créer une facture'  
   • 'aide' pour plus de commandes"
   
10. User clicks link → Logged in automatically → Dashboard

DONE. User is ready.
```

**Time to value: < 2 minutes**

### Journey 2: Create Quote (Main Use Case)

```
WhatsApp Conversation:

User: "créer un devis"

Bot: "Pour quel client ?
     
     Tapez le nom ou 'nouveau' pour créer un nouveau client."

User: "Entreprise Dubois"

Bot: "✅ Client trouvé: Entreprise Dubois
     
     Première prestation ?"

User: "Maçonnerie mur extérieur, 50m², 85€/m²"

Bot: "✅ Ajouté:
     Maçonnerie mur extérieur
     50 m² × 85,00 € = 4 250,00 €
     
     Autre prestation ? (ou 'non' pour terminer)"

User: "non"

Bot: "📊 Récapitulatif:
     
     Sous-total HT: 4 250,00 €
     TVA (20%): 850,00 €
     ─────────────────
     Total TTC: 5 100,00 €
     
     Valider ce devis ?"

User: "oui"

Bot: "⏳ Génération du PDF..."
     [Sends PDF file]
     "✅ Devis DEVIS-2025-0001 créé et envoyé !
     
     📱 Consultez-le aussi sur votre espace web:
     https://app.com/u/ABC123.../quotes"

DONE. Quote created and delivered.
```

**Time: < 1 minute**

### Journey 3: Access Web Interface

```
Scenario A: User wants to download old quote

WhatsApp:
User: "lien"

Bot: "🔗 Votre espace web:
     https://app.com/u/ABC123XYZ456...
     
     (Valide jusqu'au 15/04/2025)"

User clicks link
  → GET /u/ABC123XYZ456...
  → Validated → Session created
  → Redirected to /dashboard
  
User clicks "Mes devis"
  → GET /quotes
  → Sees all quotes
  → Clicks on quote
  → GET /quotes/42
  → Views details
  → Clicks "Download PDF"
  → GET /quotes/42/pdf
  → PDF downloaded

User closes browser. Done.

────────────────────────

Scenario B: User bookmarked magic link

User opens bookmark
  → GET /u/ABC123XYZ456... (same link, still valid)
  → Auto-logged in
  → /dashboard
  
Navigates as needed, then closes.
No login form. No password. Simple.
```

### Journey 4: Payment (Subscription)

```
After 7 days trial:

Bot (automated message):
  "⏰ Votre période d'essai se termine dans 2 jours.
   
   Pour continuer à utiliser le service, abonnez-vous:
   https://checkout.stripe.com/...
   
   Prix: 29€/mois
   Annulation à tout moment."

User clicks Stripe link
  → Stripe Checkout (external)
  → Enters payment details
  → Confirms
  
Stripe webhook:
  → POST /webhooks/stripe
  → Event: checkout.session.completed
  → Update user.subscription_status = 'active'
  
Bot confirms:
  "✅ Abonnement activé ! Merci 🎉
   
   Gérez votre abonnement ici:
   https://app.com/u/ABC123.../subscription/portal"
```

---

## Admin Routes

**Authentication:** Traditional password for admins (Devise or similar)

### Admin Dashboard

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin` | Dashboard with user count, recent activity | 1. Home |
| GET | `/admin/metrics` | Detailed analytics | 2. Metrics |

### User Management

**User Journey:** Admin → Search by Phone → View User → Manage

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin/users` | List users (search: phone, company, SIRET) | 1. List Users |
| GET | `/admin/users/:id` | View user (phone, magic link, activity, docs) | 2. User Details |
| GET | `/admin/users/:id/edit` | Edit user info | 3. Edit |
| PATCH | `/admin/users/:id` | Update user | 4. Save |
| POST | `/admin/users/:id/suspend` | Suspend account | Action: Suspend |
| POST | `/admin/users/:id/activate` | Activate account | Action: Activate |
| POST | `/admin/users/:id/regenerate_magic_link` | Generate new link + send via WhatsApp | Action: New Link |
| GET | `/admin/users/:id/logs` | Activity logs for this user | View Logs |
| POST | `/admin/users/:id/stripe_portal` | Access user's Stripe portal | Stripe Access |

**Admin Can See:**
- ✅ Phone number (primary ID)
- ✅ Company name, SIRET
- ✅ Magic link expiration date
- ✅ Last login (IP, timestamp)
- ✅ First message date
- ✅ Document counts
- ✅ Subscription status

**Admin Can Do:**
- ✅ Regenerate magic link (sends via WhatsApp)
- ✅ Suspend/activate account
- ✅ View all conversations/messages
- ✅ Access user's Stripe dashboard

### Subscriptions, Logs, Settings

| Method | Path | Description | Journey Step |
|--------|------|-------------|--------------|
| GET | `/admin/subscriptions` | All subscriptions | List |
| GET | `/admin/subscriptions/:id` | Subscription details | View |
| GET | `/admin/subscriptions/overdue` | Overdue payments | Overdue |
| GET | `/admin/logs` | System logs | Logs List |
| GET | `/admin/logs/:id` | Log details | Log Details |
| GET | `/admin/webhooks` | Webhook history | Webhooks |
| POST | `/admin/webhooks/:id/replay` | Replay webhook | Replay |
| GET | `/admin/settings` | App settings | Settings |
| PATCH | `/admin/settings` | Update settings | Save |

---

## Webhook Routes (API)

### Unipile Webhooks

| Method | Path | Description | Processing |
|--------|------|-------------|------------|
| POST | `/webhooks/unipile/messages` | Receive messages + auto-create users | Main Webhook |
| POST | `/webhooks/unipile/accounts` | Account status updates | Account Sync |

**Authentication:** Signature verification (X-Unipile-Signature header)

**Payload Processing:**
```ruby
{
  "sender": {
    "attendee_provider_id": "33612345678@s.whatsapp.net"  # Extract phone
  },
  "chat_id": "R8J-xM9WX7...",  # Store in user
  "message": "créer un devis",  # Process
  "message_id": "ykmhfXlRW0...",  # Store
  "timestamp": "2025-01-15T14:30:00Z"
}
```

### Stripe Webhooks

| Method | Path | Description | Processing |
|--------|------|-------------|------------|
| POST | `/webhooks/stripe` | Handle payment events | Subscription Updates |

**Authentication:** Stripe signature verification

**Key Events:**
- `checkout.session.completed` → Activate subscription
- `invoice.payment_failed` → Suspend + notify via WhatsApp
- `customer.subscription.deleted` → Cancel subscription

---

## Route Naming Conventions

### Patterns Used

✅ **RESTful resources:**
- `/quotes` (index)
- `/quotes/:id` (show)
- `/quotes/:id/pdf` (member action)

✅ **Underscores for multi-word:**
- `/send_whatsapp` (not `/send-whatsapp`)
- `/magic_link` (not `/magic-link`)
- `/regenerate_magic_link` (not `/regenerateMagicLink`)

✅ **English throughout:**
- `/dashboard` (not `/tableau-de-bord`)
- `/profile` (not `/profil`)
- `/quotes` (not `/devis`)

✅ **Simple, descriptive:**
- `/u/:token` (short, clean magic link URL)
- `/subscription/portal` (clear purpose)

---

## Security Implementation

### Magic Link Protection

**Rate Limiting:**
```ruby
# config/initializers/rack_attack.rb

# Limit magic link attempts per IP
Rack::Attack.throttle('magic_link/ip', limit: 10, period: 1.hour) do |req|
  req.ip if req.path.start_with?('/u/')
end

# Limit magic link attempts per token
Rack::Attack.throttle('magic_link/token', limit: 5, period: 10.minutes) do |req|
  req.params['token'] if req.path.start_with?('/u/')
end

# Limit WhatsApp webhook (prevent spam)
Rack::Attack.throttle('webhook/unipile', limit: 1000, period: 1.minute) do |req|
  'unipile' if req.path == '/webhooks/unipile/messages'
end
```

**Session Security:**
```ruby
# config/initializers/session_store.rb

Rails.application.config.session_store :cookie_store,
  key: '_btp_assistant_session',
  secure: Rails.env.production?,  # HTTPS only
  httponly: true,  # No JavaScript access
  same_site: :lax,  # CSRF protection
  expire_after: 30.days
```

**HTTPS Enforcement:**
```ruby
# config/environments/production.rb

config.force_ssl = true
config.ssl_options = {
  hsts: { subdomains: true, preload: true, expires: 1.year }
}
```

---

## Error Handling

### Magic Link Errors

| Scenario | Response | User Action |
|----------|----------|-------------|
| Invalid token | Redirect to `/` with error | Contact bot: "lien" |
| Expired token | Redirect to `/` with message | Contact bot: "lien" |
| Rate limit exceeded | 429 error page | Wait 1 hour |
| No active subscription | Redirect to payment | Pay via Stripe link |

### Webhook Errors

| Scenario | Response | Admin Action |
|----------|----------|--------------|
| Invalid signature | 401 Unauthorized | Check API keys |
| Missing data | 422 + log error | Review logs |
| Processing error | 200 (ack) + background retry | Monitor retries |

---

## Performance Optimizations

### Database Queries

**Magic Link Lookup:**
```ruby
# Fast lookup using prefix index
candidates = User.where(magic_link_token_prefix: token[0..15])
user = candidates.find { |u| u.valid_magic_link?(token) }

# vs slow (avoid)
User.all.find { |u| u.valid_magic_link?(token) }
```

**Dashboard Queries:**
```ruby
# Preload associations
@quotes = current_user.quotes
                      .includes(:client, :quote_items)
                      .order(issue_date: :desc)
                      .limit(20)
```

### Caching

```ruby
# Cache user stats
@stats = Rails.cache.fetch("user_stats_#{current_user.id}", expires_in: 5.minutes) do
  {
    quotes_count: current_user.quotes.count,
    invoices_count: current_user.invoices.count,
    clients_count: current_user.clients.count,
    total_revenue: current_user.invoices.sum(:total_amount)
  }
end
```

---

## Development Routes

**Only in development/test:**

| Method | Path | Description |
|--------|------|-------------|
| GET | `/dev/emails` | Letter Opener (preview emails) |
| GET | `/dev/sidekiq` | Sidekiq Web UI (background jobs) |
| POST | `/dev/webhooks/unipile` | Test Unipile webhook |
| POST | `/dev/webhooks/stripe` | Test Stripe webhook |
| POST | `/dev/magic_link/:user_id` | Generate test magic link |

---

## Deployment Checklist

### Environment Variables

```bash
# Unipile
UNIPILE_DSN=https://api1.unipile.com:13111
UNIPILE_API_KEY=your_api_key
UNIPILE_ACCOUNT_ID=your_whatsapp_account_id
UNIPILE_WEBHOOK_SECRET=webhook_secret_for_signature

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PRICE_ID=price_monthly_subscription

# OpenAI
OPENAI_API_KEY=sk-...

# App
SECRET_KEY_BASE=...
MAGIC_LINK_SECRET=... # For additional HMAC if needed
APP_DOMAIN=app.deviswhatsapp.com
```

### Webhook Setup

**Unipile:**
```bash
curl -X POST https://apiX.unipile.com:XXXX/api/v1/webhooks \
  -H "X-API-KEY: $UNIPILE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "source": "chats",
    "request_url": "https://app.deviswhatsapp.com/webhooks/unipile/messages",
    "name": "WhatsApp Messages"
  }'
```

**Stripe:**
```
Dashboard → Webhooks → Add endpoint
URL: https://app.deviswhatsapp.com/webhooks/stripe
Events: checkout.session.completed, invoice.*, customer.subscription.*
```

---

## Summary

### Key Differences from Traditional Apps

| Traditional App | This App (Bot-First) |
|----------------|---------------------|
| Registration form | Auto-created from WhatsApp |
| Email + Password | Phone number + Magic link |
| Email verification | WhatsApp verification (implicit) |
| Password reset flow | Request new link via bot |
| Login page | Just click link |
| Complex onboarding | Conversational onboarding |
| Web-first | WhatsApp-first |

### Benefits

✅ **User Experience:**
- Zero friction signup
- No passwords to remember
- Instant access via WhatsApp
- Web when needed (via link)

✅ **Security:**
- No password breaches
- Cryptographic tokens
- WhatsApp as natural 2FA
- Automatic expiration

✅ **Development:**
- 47 routes (vs 72)
- No Devise complexity
- No email confirmation
- Simpler codebase

✅ **Maintenance:**
- Less support tickets (no password issues)
- Easier user management (by phone)
- Clear audit trail

**This is the perfect architecture for a WhatsApp-first artisan tool.** 🚀
