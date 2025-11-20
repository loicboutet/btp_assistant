# Application Routes - Bot-First (Ultra-Minimal Web)

## Core Principle

**The application is a WhatsApp bot. The web interface exists ONLY for viewing/downloading PDFs.**

Users do NOT:
- ❌ Register on the web
- ❌ Login with password
- ❌ Connect WhatsApp (they already use WhatsApp!)
- ❌ Create documents on web (WhatsApp only)
- ❌ Manage clients on web (WhatsApp only)
- ❌ See dashboards/KPIs/metrics

Users DO:
- ✅ Message WhatsApp bot (auto-created in DB by phone number)
- ✅ Receive magic link on WhatsApp
- ✅ Click magic link → View their documents
- ✅ Download PDFs
- ✅ That's it.

---

## Public Routes (Unauthenticated)

**Landing page is optional - most users come from WhatsApp directly**

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Simple landing (SEO/info only) |
| GET | `/legal` | Legal notices |
| GET | `/terms` | Terms and conditions |
| GET | `/privacy` | Privacy policy |

**Total: 4 routes**

---

## Magic Link Authentication (No Password!)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/u/:token` | Magic link entry point - validates token, creates session, redirects |

**Flow:**
1. User receives WhatsApp message: "Votre accès: https://app.com/u/ABC123XYZ..."
2. User clicks link
3. System validates token → Creates session automatically
4. Redirects to `/quotes` (default landing after auth)
5. User is logged in (no password needed)

**Security:**
- 256-bit entropy tokens
- Bcrypt hashed in DB
- 90-day expiration
- Rate limited (10/hour per IP)
- HTTPS only

**Total: 1 route**

---

## Authenticated User Routes (Read-Only Web)

**After clicking magic link, user can access:**

### Documents (Main Purpose of Web Access)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/quotes` | List all quotes (with simple search/filters) |
| GET | `/quotes/:id` | View quote details |
| GET | `/quotes/:id/pdf` | Download quote PDF |
| GET | `/invoices` | List all invoices (with simple search/filters) |
| GET | `/invoices/:id` | View invoice details |
| GET | `/invoices/:id/pdf` | Download invoice PDF |

**Note:** Users do NOT create documents on web. Creation is WhatsApp-only.

### Account Info (Minimal)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/profile` | View company info (SIRET, address, subscription status) |
| POST | `/subscription/portal` | Redirect to Stripe Customer Portal |
| DELETE | `/logout` | Clear session (rarely used) |

**Total: 9 routes**

---

## Admin Routes

**Namespace:** `/admin`

Admin needs full visibility and control.

### Dashboard

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin` | Dashboard with user count, recent activity |
| GET | `/admin/metrics` | System metrics |

### User Management

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/users` | List users (search by phone number!) |
| GET | `/admin/users/:id` | View user (phone, magic link status, activity) |
| GET | `/admin/users/:id/edit` | Edit user info |
| PATCH | `/admin/users/:id` | Update user |
| POST | `/admin/users/:id/suspend` | Suspend account |
| POST | `/admin/users/:id/activate` | Activate account |
| POST | `/admin/users/:id/regenerate_magic_link` | Generate new magic link → Send via WhatsApp |
| GET | `/admin/users/:id/logs` | Activity logs |

**Key:** Admin searches/manages users by **phone number** (primary identifier).

### Subscriptions, Logs, Settings

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/subscriptions` | List subscriptions |
| GET | `/admin/subscriptions/:id` | View subscription (links to Stripe) |
| GET | `/admin/subscriptions/overdue` | Overdue payments |
| GET | `/admin/logs` | System logs |
| GET | `/admin/logs/:id` | Log details |
| GET | `/admin/webhooks` | Webhook activity |
| POST | `/admin/webhooks/:id/replay` | Replay failed webhook |
| GET | `/admin/settings` | App settings (API keys, etc.) |
| PATCH | `/admin/settings` | Update settings |

**Total: ~20 routes**

---

## Webhook Routes (API)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/webhooks/unipile/messages` | Receive WhatsApp messages → Auto-create users |
| POST | `/webhooks/stripe` | Handle payment events |

**Processing:**
- Extract phone number from Unipile webhook
- Find or create User by phone
- Store message
- Process via AI bot
- Send response

**Total: 2 routes**

---

## Complete Route Summary

| Category | Routes | Purpose |
|----------|--------|---------|
| Public | 4 | Landing, legal pages |
| Magic Link Auth | 1 | Auto-login from WhatsApp |
| User (Read-Only) | 9 | View/download documents |
| Admin | ~20 | Full management |
| Webhooks | 2 | Real-time processing |
| **TOTAL** | **~36 routes** | |

**Comparison:**
- Initial plan: 72 routes
- Current: **36 routes (-50%!)**

---

## What We Removed (And Why)

### ❌ Removed Routes:

**WhatsApp Connection (4 routes):**
- `/whatsapp/connect` - Not needed (users already use WhatsApp)
- `/whatsapp/status` - Not needed (no connection to check)
- `/whatsapp/disconnect` - Not needed (nothing to disconnect)
- QR code flow - Not needed (no pairing)

**Dashboard/KPIs (3 routes):**
- `/dashboard` - Not needed (no dashboard)
- Dashboard metrics - Not needed (no KPIs for users)
- Activity feeds - Not needed (users don't care)

**Client Management (7 routes):**
- `/clients` - Not needed (managed via WhatsApp)
- `/clients/new`, `/clients/create` - WhatsApp only
- `/clients/:id/edit`, `/clients/:id/update` - WhatsApp only
- `/clients/:id` - WhatsApp only
- `/clients/:id/destroy` - WhatsApp only

**Conversations (2 routes):**
- `/conversations` - Not needed (happens on WhatsApp)
- `/conversations/:id` - Not needed (users see in WhatsApp)

**Registration (7 routes):**
- `/sign_up` form - Not needed (auto-created from WhatsApp)
- Email/password auth - Not needed (magic links)
- Password reset - Not needed (no passwords)
- Email confirmation - Not needed (phone is verification)

**Quote/Invoice Actions (6 routes):**
- `/quotes/new`, `/quotes/create` - WhatsApp only
- `/quotes/:id/edit`, `/quotes/:id/update` - WhatsApp only
- `/quotes/:id/send_whatsapp` - Not needed (already sent from bot)
- Same for invoices

**Total Removed: 29 routes**

---

## WhatsApp Commands (Primary Interface)

Users interact via WhatsApp messages (NOT web routes):

| Command (FR) | Command (TR) | Action |
|--------------|--------------|--------|
| "Bonjour" (first time) | "Merhaba" | Auto-create user, start onboarding |
| "créer un devis" | "teklif oluştur" | Create quote workflow |
| "créer une facture" | "fatura oluştur" | Create invoice workflow |
| "nouveau client" | "yeni müşteri" | Add client workflow |
| "mes devis" | "tekliflerim" | List recent quotes |
| "lien" / "web" | "bağlantı" | Get/regenerate magic link |
| "aide" | "yardım" | Show help menu |

**Everything happens on WhatsApp. Web is just for viewing PDFs.**

---

## Complete User Journey

### New User (First Time)

```
1. User: Messages WhatsApp bot "Bonjour"
   → Bot: Détecte nouveau numéro
   → DB: Crée User avec phone_number = "+33612345678"
   
2. Bot: "Bienvenue ! Nom de votre entreprise ?"
   User: "Maçonnerie Dubois"
   Bot: "SIRET ?"
   User: "12345678901234"
   → DB: Enregistre company_name, siret
   
3. Bot: "Parfait ! Voici votre accès web: https://app.com/u/ABC123..."
   → DB: Génère magic_link_token, envoie URL
   
4. User: Clique le lien
   → GET /u/ABC123...
   → Session créée
   → Redirect /quotes
   
5. User: Voit ses devis (vide pour l'instant)
   User: Ferme le navigateur
   
6. User: WhatsApp "créer un devis"
   → Bot guide la création
   → PDF envoyé sur WhatsApp
   → DB: Quote enregistré
   
7. Plus tard, User clique à nouveau le magic link
   → Voit le devis dans /quotes
   → Download PDF
   → Ferme navigateur
```

**Key Insight:** L'utilisateur va sur le web **uniquement pour télécharger des PDFs**. Tout le reste se passe sur WhatsApp.

### Existing User (Daily Use)

```
99% du temps:
  WhatsApp uniquement
  "créer un devis" → Bot → PDF sur WhatsApp
  "créer une facture" → Bot → PDF sur WhatsApp
  JAMAIS besoin du web

1% du temps:
  Comptable demande un PDF
  → User clique magic link (bookmarké)
  → Télécharge PDF
  → Envoie au comptable
  → Ferme navigateur
```

---

## Security & Implementation

### Magic Link Implementation

**Generation:**
```ruby
# When user completes onboarding via WhatsApp
token = SecureRandom.urlsafe_base64(32) # 256 bits
user.update!(
  magic_link_token_digest: BCrypt::Password.create(token),
  magic_link_expires_at: 90.days.from_now
)

# Send via WhatsApp
send_whatsapp("Votre accès: https://app.com/u/#{token}")
```

**Validation:**
```ruby
# GET /u/:token
def show
  user = User.find_by_magic_link(params[:token])
  
  if user && !user.magic_link_expired?
    session[:user_id] = user.id
    redirect_to quotes_path
  else
    redirect_to root_path, alert: "Lien invalide ou expiré"
  end
end
```

**Rate Limiting:**
```ruby
# config/initializers/rack_attack.rb
Rack::Attack.throttle('magic_link/ip', limit: 10, period: 1.hour) do |req|
  req.ip if req.path.start_with?('/u/')
end
```

---

## Webhook Processing

### Unipile Webhook (Auto-Create Users)

```ruby
# POST /webhooks/unipile/messages

def create
  phone = extract_phone(params[:sender]) # "+33612345678"
  
  # Find or create user
  user = User.find_or_create_by!(phone_number: phone) do |u|
    u.unipile_chat_id = params[:chat_id]
    u.first_message_at = Time.current
  end
  
  # Process message
  WhatsappBot::MessageProcessor.call(user, params[:message])
  
  head :ok
end
```

### Stripe Webhook (Subscription Management)

```ruby
# POST /webhooks/stripe

def create
  case event.type
  when 'invoice.payment_succeeded'
    user.update!(subscription_status: 'active')
  when 'invoice.payment_failed'
    user.update!(subscription_status: 'suspended')
    send_whatsapp(user.phone, "Paiement échoué. Mettez à jour: #{portal_link}")
  end
  
  head :ok
end
```

---

## File Structure

### Controllers Needed:

```
app/controllers/
  magic_links_controller.rb      # GET /u/:token
  quotes_controller.rb            # index, show, pdf
  invoices_controller.rb          # index, show, pdf
  profile_controller.rb           # show
  subscriptions_controller.rb     # portal redirect
  sessions_controller.rb          # logout only
  
  webhooks/
    unipile_controller.rb         # POST /webhooks/unipile/messages
    stripe_controller.rb          # POST /webhooks/stripe
  
  admin/
    dashboard_controller.rb
    users_controller.rb
    subscriptions_controller.rb
    logs_controller.rb
    webhooks_controller.rb
    settings_controller.rb
```

**Total: ~15 controllers** (vs 25+ in original plan)

---

## Views Needed:

```
app/views/
  quotes/
    index.html.erb   # Simple list with search/filters
    show.html.erb    # Document details + PDF download button
  
  invoices/
    index.html.erb   # Simple list
    show.html.erb    # Document details
  
  profile/
    show.html.erb    # Company info + subscription status
  
  pages/
    landing.html.erb
    legal.html.erb
    terms.html.erb
    privacy.html.erb
  
  admin/
    (full admin views as needed)
```

**Total: ~10 user views** (vs 30+ in original plan)

---

## Conclusion

This ultra-minimal web interface is **perfect for the bot-first architecture**:

✅ **Users don't need web** - 99% WhatsApp usage
✅ **Web is just PDF viewer** - Simple, focused
✅ **No confusing features** - No dashboards, no settings
✅ **Faster development** - 36 routes vs 72 (-50%)
✅ **Less maintenance** - Fewer features = fewer bugs
✅ **Better UX** - Users stay in WhatsApp (their comfort zone)

**The web app is basically a secure file server with magic link authentication. Nothing more, nothing less.**
