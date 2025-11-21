# Views To Update - Bot-First Simplification

## Current State vs Required State

### ✅ Already Updated (Mockups Only)

- `app/views/mockups/user_dashboard.html.erb` - ✅ Simplified to 2 cards
- `app/views/mockups/user_quotes_list.html.erb` - ✅ No KPIs
- `app/views/mockups/user_profile.html.erb` - ✅ Minimal
- `app/views/mockups/signup_success.html.erb` - ✅ WhatsApp link

### ❌ Need to Update (Real App Views)

#### 1. Dashboard (`app/views/dashboard/index.html.erb`)

**Current:** Complex dashboard with:
- WhatsApp connection prompts
- 4 KPI cards (quotes, invoices, clients, revenue)
- Recent activity feed
- Quick actions
- "How it works" explanation

**Required:** ULTRA-SIMPLE
- Just 2 big cards:
  - "Mes devis" → links to /quotes
  - "Mes factures" → links to /invoices
- WhatsApp icon (opens chat)
- Hamburger menu (devis, factures, compte, abonnement)
- NO KPIs, NO stats, NO connection prompt

**Status:** ✅ Updated

---

#### 2. Quotes Index (`app/views/quotes/index.html.erb`)

**Current:** Complex with:
- 4 KPI cards at top (total quotes, pending, accepted, total amount)
- Complex filters (status, client, date range)
- Table layout
- Pagination

**Required:** MINIMAL
- Simple search bar (rounded pill)
- 2 filter pills (clients, mois)
- Clean list of cards (NOT table)
- Each card: number, client, date, amount, download PDF button
- NO KPIs at all

**Status:** ✅ Updated

---

#### 3. Invoices Index (`app/views/invoices/index.html.erb`)

**Current:** Same as quotes - complex with KPIs

**Required:** Same as quotes - minimal
- Search + 2 filters
- Card list
- NO KPIs

**Status:** ✅ Updated

---

#### 4. Clients Index (`app/views/clients/index.html.erb`)

**Current:** Full CRUD interface with:
- 4 KPI cards
- Complex table
- Create/edit/delete functionality
- Filters

**Required:** **DELETE THIS COMPLETELY**
- Clients are managed via WhatsApp ONLY
- No web interface for clients at all
- Route should redirect to WhatsApp with message

**Status:** ❌ TO DELETE

---

#### 5. Profile (`app/views/profile/show.html.erb`)

**Current:** Multiple cards:
- Personal info (email, password, etc.)
- Business info
- WhatsApp connection status
- Subscription info
- Security (change password)

**Required:** MINIMAL
- Just company info (SIRET, address, phone, language)
- Subscription status
- Link to Stripe portal
- WhatsApp help card
- NO password section (no passwords!)
- NO WhatsApp connection section (not needed!)

**Status:** ✅ Updated

---

#### 6. Conversations (`app/views/conversations/index.html.erb` & `show.html.erb`)

**Current:** Probably shows WhatsApp conversation history

**Required:** **DELETE COMPLETELY**
- Users see conversations in WhatsApp
- No need for web interface
- Routes should be removed

**Status:** ❌ TO DELETE

---

#### 7. WhatsApp Connect (`app/views/whatsapp/connect.html.erb`)

**Current:** QR code connection interface

**Required:** **DELETE COMPLETELY**
- No QR code needed
- Users don't "connect" WhatsApp
- They just message the bot
- Routes should be removed

**Status:** ❌ TO DELETE

---

## Routes to Remove from config/routes.rb

```ruby
# REMOVE THESE - Not needed in bot-first architecture

# WhatsApp Connection (users don't connect!)
get 'whatsapp/connect'
post 'whatsapp/connect'
get 'whatsapp/status'
delete 'whatsapp/disconnect'

# Clients Management (WhatsApp only!)
resources :clients  # DELETE entire resource

# Conversations (happens on WhatsApp!)
resources :conversations  # DELETE entire resource

# Password Management (no passwords!)
devise_for :users  # REPLACE with simple session for magic links
```

---

## Routes to KEEP

```ruby
# Magic Link Auth
get '/u/:token', to: 'magic_links#show'

# Documents (Read-Only)
resources :quotes, only: [:index, :show] do
  get :pdf, on: :member
end

resources :invoices, only: [:index, :show] do
  get :pdf, on: :member
end

# Profile (Read-Only)
get '/profile', to: 'profile#show'

# Subscription (Stripe Portal Redirect)
post '/subscription/portal', to: 'subscriptions#portal'

# Logout
delete '/logout', to: 'sessions#destroy'

# Webhooks
post '/webhooks/unipile/messages'
post '/webhooks/stripe'

# Admin (keep all)
namespace :admin do
  # ... all admin routes
end
```

---

## Controllers to DELETE/Simplify

### DELETE Completely:
- `app/controllers/whatsapp_controller.rb` - Not needed
- `app/controllers/conversations_controller.rb` - Not needed
- `app/controllers/users/passwords_controller.rb` - No passwords
- `app/controllers/users/registrations_controller.rb` - No registration
- `app/controllers/registrations_controller.rb` - No registration

### KEEP/Simplify:
- `app/controllers/magic_links_controller.rb` - CREATE THIS (magic link auth)
- `app/controllers/quotes_controller.rb` - index, show, pdf only
- `app/controllers/invoices_controller.rb` - index, show, pdf only
- `app/controllers/profile_controller.rb` - show only (read-only)
- `app/controllers/subscriptions_controller.rb` - portal redirect only
- `app/controllers/webhooks/*` - Keep all

---

## Views to DELETE

```
app/views/whatsapp/
  connect.html.erb  ❌ DELETE
  
app/views/conversations/
  index.html.erb  ❌ DELETE
  show.html.erb  ❌ DELETE
  
app/views/clients/
  index.html.erb  ❌ DELETE
  show.html.erb  ❌ DELETE
  new.html.erb  ❌ DELETE
  edit.html.erb  ❌ DELETE
  
app/views/devise/
  (entire directory)  ❌ DELETE (no passwords!)
  
app/views/users/
  (registration/password views)  ❌ DELETE
```

---

## New Views to CREATE

```
app/views/magic_links/
  show.html.erb  ✅ CREATE (handles /u/:token - just redirects)
  
app/views/quotes/
  index.html.erb  ✅ UPDATED (no KPIs)
  show.html.erb  ⚠️ UPDATE (minimal - just PDF preview + download)
  
app/views/invoices/
  index.html.erb  ✅ UPDATED (no KPIs)
  show.html.erb  ⚠️ UPDATE (minimal)
  
app/views/profile/
  show.html.erb  ✅ UPDATED (no password section)
```

---

## Layout Changes

### Current Layout (`app/views/layouts/client.html.erb`)

**Probably has:**
- Complex navigation
- User menu dropdown
- Notifications
- Breadcrumbs

**Required:** MINIMAL
- WhatsApp icon (top-left)
- Hamburger menu (top-right)
- That's it!
- No complex navigation

---

## Summary of Changes

### DELETE (Not Needed):
- WhatsApp connection pages ❌
- Clients management pages ❌
- Conversations pages ❌
- Registration/password pages ❌
- Complex dashboards ❌
- KPI cards ❌

### KEEP (Essential):
- Quotes index + show + PDF download ✅
- Invoices index + show + PDF download ✅
- Profile (minimal info) ✅
- Subscription → Stripe portal ✅
- Magic link entry point ✅

### CREATE (New):
- MagicLinksController ✅
- Magic link validation logic ✅

---

## Implementation Priority

1. **First:** Update existing views (dashboard, quotes, invoices, profile)
2. **Second:** Delete unnecessary views (clients, conversations, whatsapp, devise)
3. **Third:** Update routes.rb (remove unused routes)
4. **Fourth:** Delete unused controllers
5. **Fifth:** Create MagicLinksController
6. **Last:** Update layout to be minimal

---

## Testing Checklist

After changes:
- [ ] Magic link works (click → auto-login)
- [ ] Quotes list shows (no KPIs)
- [ ] Invoices list shows (no KPIs)
- [ ] PDF download works
- [ ] Profile shows company info
- [ ] Stripe portal redirect works
- [ ] WhatsApp links work (open chat)
- [ ] Menu works (hamburger)
- [ ] No broken links (clients, conversations, etc.)
- [ ] Mobile responsive
