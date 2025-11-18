# Data Model - Bot-First Architecture

## Overview

This document describes all the objects (models) of the application and their relationships. The application is **bot-first**: users are automatically created when they message the WhatsApp bot and access the web via secure magic links.

## Core Principles

1. **No passwords** - Users authenticate via magic links sent on WhatsApp
2. **Phone number as identity** - Unique identifier for each user
3. **Auto-creation** - Users created automatically on first WhatsApp message
4. **WhatsApp-first** - Web interface is secondary (view-only mostly)

---

## Core Models

### User (Artisan/Entrepreneur)

The main user of the application - automatically created from WhatsApp interaction.

**Attributes:**
- `id` (primary key)
- `phone_number` (string, unique, required) - E.164 format: +33612345678
- `company_name` (string, optional) - Collected via bot
- `siret` (string, optional) - Collected via bot
- `address` (text, optional) - Collected via bot
- `vat_number` (string, optional)
- `preferred_language` (enum: 'fr', 'tr', required, default: 'fr')
- `stripe_customer_id` (string, optional, indexed)
- `subscription_status` (enum: 'trialing', 'active', 'past_due', 'canceled', default: 'trialing')
- `onboarding_completed` (boolean, default: false)
- `first_message_at` (datetime, required)
- `last_activity_at` (datetime, required)
- `timestamps` (created_at, updated_at)

**Magic Link Authentication:**
- `magic_link_token_digest` (string, unique, indexed) - Bcrypt hashed token
- `magic_link_expires_at` (datetime)
- `magic_link_last_used_at` (datetime)
- `magic_link_sent` (boolean, default: false)
- `last_login_ip` (string, optional)
- `last_login_at` (datetime, optional)

**Unipile Integration:**
- `unipile_chat_id` (string, indexed) - Unipile's chat ID
- `unipile_attendee_id` (string, indexed) - Unipile's attendee ID

**Relationships:**
- has_one :subscription
- has_many :subscription_invoices
- has_many :clients
- has_many :quotes
- has_many :invoices
- has_many :whatsapp_messages
- has_many :conversations

**Key Methods:**
```ruby
def generate_magic_link!
  # Generate secure token, hash it, store digest
  # Returns unhashed token (send via WhatsApp)
end

def magic_link_url
  # Returns: https://app.com/u/ABC123XYZ456...
end

def valid_magic_link?(token)
  # Validates token against digest and expiration
end

def display_name
  company_name || phone_number
end

def active_subscription?
  subscription_status.in?(['trialing', 'active'])
end
```

---

### WhatsappMessage

Individual WhatsApp messages exchanged with the bot.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `conversation_id` (foreign key, optional) - If part of a workflow
- `unipile_message_id` (string, unique, required)
- `unipile_chat_id` (string, required)
- `direction` (enum: 'inbound', 'outbound', required)
- `message_type` (enum: 'text', 'audio', 'image', 'document', 'video', required)
- `content` (text, optional) - Text content or transcription
- `sender_phone` (string, required) - Phone number of sender
- `attachments` (json, optional) - Unipile attachment metadata
- `audio_transcription` (text, optional) - Whisper API result
- `detected_language` (string, optional) - 'fr' or 'tr'
- `processed` (boolean, default: false)
- `sent_at` (datetime, required)
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- belongs_to :conversation (optional)

**Indexes:**
- `user_id, sent_at DESC`
- `unipile_message_id` (unique)
- `unipile_chat_id`

---

### Conversation

Tracks conversation workflows (quote creation, invoice creation, etc.).

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `conversation_type` (enum: 'quote_creation', 'invoice_creation', 'client_creation', 'onboarding', 'general', required)
- `status` (enum: 'active', 'completed', 'abandoned', 'error', default: 'active')
- `current_step` (string, optional) - Workflow state machine step
- `context_data` (json, optional) - Collected data during workflow
- `language` (enum: 'fr', 'tr', required)
- `started_at` (datetime, required)
- `completed_at` (datetime, optional)
- `last_interaction_at` (datetime, required)
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- has_many :whatsapp_messages
- belongs_to :quote (optional) - If created a quote
- belongs_to :invoice (optional) - If created an invoice
- belongs_to :client (optional) - If created a client

**Business Logic:**
- One active conversation per user at a time
- Abandoned if no interaction for 30 minutes
- Context data stores partial info during multi-step flows

---

### Client (End Customer)

The artisan's customers for whom quotes and invoices are created.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `name` (string, required)
- `address` (text, required)
- `siret` (string, optional) - If professional client
- `contact_phone` (string, optional)
- `contact_email` (string, optional)
- `created_via` (enum: 'whatsapp', 'admin', default: 'whatsapp')
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- has_many :quotes
- has_many :invoices

**Indexes:**
- `user_id`
- `user_id, name`

---

### Quote (Devis)

Commercial quotes created via WhatsApp.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `client_id` (foreign key, required)
- `conversation_id` (foreign key, optional)
- `quote_number` (string, unique, required) - Format: DEVIS-YYYY-NNNN
- `issue_date` (date, required)
- `validity_date` (date, optional)
- `status` (enum: 'draft', 'sent', 'accepted', 'rejected', default: 'sent')
- `subtotal_amount` (decimal, required)
- `vat_rate` (decimal, default: 20.0)
- `vat_amount` (decimal, required)
- `total_amount` (decimal, required)
- `notes` (text, optional)
- `pdf_path` (string, required) - Active Storage path
- `sent_via_whatsapp_at` (datetime, required)
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- belongs_to :client
- belongs_to :conversation (optional)
- has_many :quote_items (dependent: :destroy)
- has_many :invoices
- has_one_attached :pdf_file

**Indexes:**
- `user_id, issue_date DESC`
- `quote_number` (unique)
- `user_id, status`

---

### QuoteItem

Line items within a quote.

**Attributes:**
- `id` (primary key)
- `quote_id` (foreign key, required)
- `description` (text, required)
- `quantity` (decimal, required)
- `unit_price` (decimal, required)
- `total_price` (decimal, required) - Calculated: quantity * unit_price
- `position` (integer, default: 0)
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :quote

---

### Invoice (Facture)

Invoices created via WhatsApp.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `client_id` (foreign key, required)
- `quote_id` (foreign key, optional) - Link to quote if based on one
- `conversation_id` (foreign key, optional)
- `invoice_number` (string, unique, required) - Format: FACT-YYYY-NNNN
- `issue_date` (date, required)
- `due_date` (date, optional)
- `status` (enum: 'draft', 'sent', 'paid', 'overdue', default: 'sent')
- `subtotal_amount` (decimal, required)
- `vat_rate` (decimal, default: 20.0)
- `vat_amount` (decimal, required)
- `total_amount` (decimal, required)
- `notes` (text, optional)
- `pdf_path` (string, required)
- `sent_via_whatsapp_at` (datetime, required)
- `paid_at` (datetime, optional)
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- belongs_to :client
- belongs_to :quote (optional)
- belongs_to :conversation (optional)
- has_many :invoice_items (dependent: :destroy)
- has_one_attached :pdf_file

**Indexes:**
- `user_id, issue_date DESC`
- `invoice_number` (unique)
- `user_id, status`

---

### InvoiceItem

Line items within an invoice.

**Attributes:**
- `id` (primary key)
- `invoice_id` (foreign key, required)
- `description` (text, required)
- `quantity` (decimal, required)
- `unit_price` (decimal, required)
- `total_price` (decimal, required)
- `position` (integer, default: 0)
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :invoice

---

### Subscription

User's subscription to the service.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `stripe_subscription_id` (string, unique, required)
- `status` (enum: 'trialing', 'active', 'past_due', 'canceled', required)
- `trial_ends_at` (datetime, optional)
- `current_period_start` (datetime, required)
- `current_period_end` (datetime, required)
- `cancel_at_period_end` (boolean, default: false)
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- has_many :subscription_invoices

---

### SubscriptionInvoice

Monthly subscription invoices from Stripe.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `subscription_id` (foreign key, required)
- `stripe_invoice_id` (string, unique, required)
- `invoice_number` (string, unique, required) - Format: ABO-YYYY-NNNN
- `amount` (decimal, required)
- `status` (enum: 'draft', 'open', 'paid', 'void', 'uncollectible', required)
- `period_start` (date, required)
- `period_end` (date, required)
- `issue_date` (date, required)
- `due_date` (date, optional)
- `paid_at` (datetime, optional)
- `stripe_invoice_url` (string, optional) - Stripe hosted invoice
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- belongs_to :subscription

---

### SystemLog

Audit trail for admin monitoring.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, optional)
- `log_type` (enum: 'info', 'warning', 'error', 'audit', required)
- `event` (string, required) - Event name (e.g., 'user.created', 'magic_link.used')
- `description` (text, optional)
- `metadata` (json, optional) - Additional context
- `ip_address` (string, optional)
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user (optional)

**Indexes:**
- `user_id, created_at DESC`
- `event, created_at DESC`
- `log_type`

---

## Relationship Diagram

```
User (Created from WhatsApp)
│
├── Phone Number (+33612345678) → PRIMARY IDENTIFIER
├── Magic Link Token (hashed) → WEB ACCESS
├── Unipile Chat ID → WHATSAPP CONNECTION
│
├── has_many :whatsapp_messages
│   └── WhatsappMessage
│       └── belongs_to :conversation (optional)
│
├── has_many :conversations
│   └── Conversation (Workflow State Machine)
│       ├── has_many :whatsapp_messages
│       └── can create: Quote, Invoice, or Client
│
├── has_many :clients
│   └── Client
│       ├── has_many :quotes
│       └── has_many :invoices
│
├── has_many :quotes
│   └── Quote
│       ├── belongs_to :client
│       ├── belongs_to :conversation (optional)
│       ├── has_many :quote_items
│       └── has_many :invoices
│
├── has_many :invoices
│   └── Invoice
│       ├── belongs_to :client
│       ├── belongs_to :quote (optional)
│       ├── belongs_to :conversation (optional)
│       └── has_many :invoice_items
│
├── has_one :subscription
│   └── Subscription
│       └── has_many :subscription_invoices
│           └── SubscriptionInvoice
│
└── has_many :system_logs
    └── SystemLog
```

---

## User Lifecycle

### State Transitions

```
1. NEW (First WhatsApp Message)
   ├─ phone_number: captured
   ├─ subscription_status: 'trialing'
   ├─ onboarding_completed: false
   └─ first_message_at: now
   
2. ONBOARDING (Bot Collects Info)
   ├─ company_name: collected
   ├─ siret: collected
   ├─ address: collected
   └─ preferred_language: detected/confirmed
   
3. ONBOARDED (Ready to Use)
   ├─ onboarding_completed: true
   ├─ magic_link generated
   ├─ magic_link sent via WhatsApp
   └─ Can create quotes/invoices
   
4. SUBSCRIBED (Paid)
   ├─ stripe_customer_id: set
   ├─ subscription created
   └─ subscription_status: 'active'
   
5. SUSPENDED (Payment Failed)
   ├─ subscription_status: 'past_due' or 'canceled'
   └─ Cannot create new documents
```

---

## Magic Link Security Model

### Token Generation

```ruby
# When user completes onboarding
token = SecureRandom.urlsafe_base64(32) # 256 bits entropy
# Example: "ABCdef123XYZ789-_ABCdef123XYZ789-_ABCdef"

# Hash it before storage
digest = BCrypt::Password.create(token)

# Store only digest
user.update!(
  magic_link_token_digest: digest,
  magic_link_expires_at: 90.days.from_now
)

# Return token to send via WhatsApp (NEVER stored unhashed)
return token
```

### URL Structure

```
https://app.deviswhatsapp.com/u/ABCdef123XYZ789-_ABCdef123XYZ789-_ABCdef
                            │  │
                            │  └─ Token (32 bytes, URL-safe base64)
                            └─ Magic link endpoint
```

### Token Validation Flow

```ruby
# GET /u/:token
# app/controllers/magic_links_controller.rb

def show
  token = params[:token]
  
  # Find user by matching token digest
  user = User.find_each.find do |u|
    u.valid_magic_link?(token)
  end
  
  if user.nil?
    # Token not found or invalid
    redirect_to root_path, alert: "Lien invalide"
    log_security_event('magic_link.invalid', token: token[0..10])
    return
  end
  
  if user.magic_link_expires_at < Time.current
    # Expired
    redirect_to root_path, alert: "Lien expiré. Demandez un nouveau lien sur WhatsApp."
    log_security_event('magic_link.expired', user_id: user.id)
    return
  end
  
  # Valid! Create session
  session[:user_id] = user.id
  user.use_magic_link! # Update last_used_at and IP
  
  redirect_to dashboard_path, notice: "Bienvenue #{user.display_name} !"
end
```

### Security Enhancements

**Optimized Token Lookup:**
```ruby
# Instead of finding each user and checking bcrypt (slow)
# Use a secondary index on first 16 chars of token

# Migration
add_column :users, :magic_link_token_prefix, :string, limit: 16
add_index :users, :magic_link_token_prefix

# On generation
token = SecureRandom.urlsafe_base64(32)
user.magic_link_token_prefix = token[0..15]
user.magic_link_token_digest = BCrypt::Password.create(token)

# On validation
candidates = User.where(magic_link_token_prefix: token[0..15])
user = candidates.find { |u| u.valid_magic_link?(token) }
```

**Rate Limiting:**
```ruby
# config/initializers/rack_attack.rb
Rack::Attack.throttle('magic_link/ip', limit: 10, period: 1.hour) do |req|
  req.ip if req.path.start_with?('/u/')
end

Rack::Attack.throttle('magic_link/token', limit: 5, period: 10.minutes) do |req|
  req.params['token'] if req.path.start_with?('/u/')
end
```

**IP Validation (Optional):**
```ruby
# Track country from first login
user.update!(expected_country: ip_to_country(request.remote_ip))

# On subsequent logins, alert if different country
if ip_to_country(request.remote_ip) != user.expected_country
  notify_admin_suspicious_login(user, request.remote_ip)
end
```

---

## Unipile Integration

### Webhook: New Message → Auto-Create User

```ruby
# app/controllers/webhooks/unipile_controller.rb

def messages
  payload = webhook_payload
  
  # Extract phone number
  sender_id = payload.dig('sender', 'attendee_provider_id')
  # Example: "33612345678@s.whatsapp.net"
  phone_number = normalize_phone(sender_id)
  # Result: "+33612345678"
  
  # Find or create user
  user = User.find_or_create_by!(phone_number: phone_number) do |u|
    u.unipile_chat_id = payload['chat_id']
    u.unipile_attendee_id = payload.dig('sender', 'attendee_id')
    u.first_message_at = Time.current
    u.last_activity_at = Time.current
    u.preferred_language = detect_language_from_phone(phone_number)
  end
  
  # Store message
  message = user.whatsapp_messages.create!(
    unipile_message_id: payload['message_id'],
    unipile_chat_id: payload['chat_id'],
    direction: 'inbound',
    content: payload['message'],
    message_type: detect_message_type(payload),
    sender_phone: phone_number,
    attachments: payload['attachments'],
    sent_at: payload['timestamp']
  )
  
  # Process message
  WhatsappBot::MessageProcessor.call(user, message)
  
  head :ok
end

private

def normalize_phone(whatsapp_id)
  # "33612345678@s.whatsapp.net" → "+33612345678"
  number = whatsapp_id.split('@').first
  "+#{number}"
end

def detect_language_from_phone(phone)
  case phone[0..2]
  when '+33' then 'fr'
  when '+90' then 'tr'
  else 'fr'
  end
end
```

### One Business Number for All Users

**Architecture:**
- ONE WhatsApp business number (e.g., +33 6 12 00 00 00)
- Connected via Unipile (admin does this once)
- All users message this same number
- Bot identifies user by sender phone number
- No per-user WhatsApp connection needed

**Benefits:**
- ✅ Simpler setup
- ✅ No QR code needed
- ✅ Users just message a number
- ✅ One Unipile account to manage

---

## Document Numbering

### Auto-increment per User per Year

```ruby
# app/models/quote.rb

before_validation :generate_quote_number, on: :create

def generate_quote_number
  return if quote_number.present?
  
  year = issue_date.year
  last_number = user.quotes
                    .where("issue_date >= ? AND issue_date < ?", 
                           Date.new(year, 1, 1), 
                           Date.new(year + 1, 1, 1))
                    .maximum(:quote_number)
  
  if last_number
    # Extract number: "DEVIS-2024-0042" → 42
    current_num = last_number.split('-').last.to_i
    next_num = current_num + 1
  else
    next_num = 1
  end
  
  self.quote_number = "DEVIS-#{year}-#{next_num.to_s.rjust(4, '0')}"
end
```

**Formats:**
- Quotes: `DEVIS-2025-0001`, `DEVIS-2025-0002`, etc.
- Invoices: `FACT-2025-0001`, `FACT-2025-0002`, etc.
- Subscription Invoices: `ABO-2025-0001`, `ABO-2025-0002`, etc.

---

## Conversation Workflow States

### Quote Creation Workflow

```ruby
# context_data structure during workflow
{
  "workflow": "quote_creation",
  "steps_completed": ["client_selected", "item_1_added", "item_2_added"],
  "current_step": "review_total",
  "data": {
    "client_id": 123,
    "client_name": "Entreprise Dubois",
    "items": [
      {
        "description": "Maçonnerie mur extérieur",
        "quantity": 50.0,
        "unit_price": 85.0,
        "total": 4250.0
      }
    ],
    "subtotal": 4250.0,
    "vat_rate": 20.0,
    "vat_amount": 850.0,
    "total": 5100.0
  },
  "retry_count": 0,
  "last_bot_message": "Total HT: 4250€..."
}
```

**States:**
1. `initiated` → User triggers creation
2. `client_selection` → Select or create client
3. `client_confirmed` → Client locked
4. `collecting_items` → Add line items (loop)
5. `items_confirmed` → All items added
6. `reviewing_total` → Show totals, ask confirmation
7. `generating_pdf` → Create PDF
8. `sending_pdf` → Send via WhatsApp
9. `completed` → Done!

### Onboarding Workflow

```ruby
# First-time user workflow
{
  "workflow": "onboarding",
  "current_step": "collect_siret",
  "data": {
    "company_name": "Maçonnerie Dubois",
    "siret": null,
    "address": null,
    "vat_number": null
  }
}
```

**States:**
1. `welcome` → Greet new user
2. `collect_company_name` → Ask company name
3. `collect_siret` → Ask SIRET
4. `collect_address` → Ask address
5. `collect_vat` → Ask VAT (optional)
6. `confirm_info` → Show summary, confirm
7. `completed` → Mark onboarding_completed, send magic link

---

## Indexes & Performance

### Critical Indexes

```ruby
# User lookups
add_index :users, :phone_number, unique: true
add_index :users, :magic_link_token_prefix # Fast magic link lookup
add_index :users, :stripe_customer_id
add_index :users, :unipile_chat_id
add_index :users, :subscription_status

# Message queries
add_index :whatsapp_messages, [:user_id, :sent_at]
add_index :whatsapp_messages, :unipile_message_id, unique: true
add_index :whatsapp_messages, :unipile_chat_id

# Document queries
add_index :quotes, [:user_id, :issue_date]
add_index :quotes, :quote_number, unique: true
add_index :invoices, [:user_id, :issue_date]
add_index :invoices, :invoice_number, unique: true

# Conversation lookups
add_index :conversations, [:user_id, :status]
add_index :conversations, :last_interaction_at
```

### Query Optimization

```ruby
# Dashboard - Recent activity
user.quotes.includes(:client, :quote_items)
     .order(issue_date: :desc)
     .limit(10)

# Admin - User list with stats
User.left_joins(:quotes, :invoices)
    .select('users.*, 
             COUNT(DISTINCT quotes.id) as quotes_count,
             COUNT(DISTINCT invoices.id) as invoices_count')
    .group('users.id')
    .order(last_activity_at: :desc)
```

---

## External Service Integrations

### Unipile (WhatsApp Bot)

**Connection:**
- Admin manually connects business WhatsApp account
- Store Unipile account ID in environment variable
- Webhook URL: `https://app.com/webhooks/unipile/messages`

**Mapping:**
- `User.phone_number` ← Extracted from `sender.attendee_provider_id`
- `User.unipile_chat_id` ← `payload.chat_id`
- `User.unipile_attendee_id` ← `sender.attendee_id`

### Stripe (Payments)

**Connection:**
- `User.stripe_customer_id` ← Stripe Customer ID
- `Subscription.stripe_subscription_id` ← Stripe Subscription ID
- Webhook URL: `https://app.com/webhooks/stripe`

**Flow:**
1. User completes onboarding via WhatsApp
2. Bot sends Stripe Checkout link via WhatsApp
3. User pays → Webhook activates subscription
4. No web registration form needed

### OpenAI (AI Processing)

**Whisper API:**
- Audio messages → Transcription
- Language detection (fr/tr)

**GPT-4 API:**
- Message understanding
- Conversation flow management
- Structured data extraction

---

## Security Considerations

### Magic Link Best Practices

✅ **Implemented:**
- 256-bit entropy tokens
- Bcrypt hashing (cost: 12)
- 90-day expiration
- Rate limiting (10/hour per IP)
- HTTPS only
- HttpOnly session cookies
- IP tracking
- Usage timestamps

🔜 **Optional Enhancements:**
- Email notification on web login (if email collected)
- WhatsApp notification on web login ("Someone accessed your account")
- Geolocation alerts (different country)
- Single-use mode (invalidate after first use)
- Device fingerprinting

### Data Protection

**Stored in Database:**
- Phone number (encrypted at rest)
- Magic link digest (bcrypt)
- Stripe IDs
- Company info

**Never Stored:**
- Passwords (don't exist)
- Raw magic link tokens (only sent once)
- Credit card info (Stripe handles)

**Encryption at Rest:**
```ruby
# config/credentials.yml.enc
active_record_encryption:
  primary_key: ...
  deterministic_key: ...
  key_derivation_salt: ...

# app/models/user.rb
encrypts :phone_number, deterministic: true
encrypts :vat_number
```

---

## Admin Visibility

### User Identification in Admin

**Admin can see:**
- ✅ Phone number (primary identifier)
- ✅ Company name
- ✅ SIRET
- ✅ First message date
- ✅ Last activity
- ✅ Subscription status
- ✅ Magic link expiration
- ✅ Number of documents created
- ✅ Login history (IPs, timestamps)

**Admin can do:**
- Regenerate magic link (sends new link via WhatsApp)
- Suspend account
- Activate account
- View all messages/conversations
- Access user's Stripe dashboard
- View system logs for this user

**Admin cannot:**
- Login as user (no password)
- View magic link token (only digest stored)
- Bypass magic link security

---

## Data Retention & GDPR

### User Deletion

```ruby
# app/models/user.rb

def destroy_with_gdpr_compliance
  # Keep financial records (legal requirement: 10 years)
  quotes.update_all(user_id: nil, gdpr_anonymized: true)
  invoices.update_all(user_id: nil, gdpr_anonymized: true)
  subscription_invoices.update_all(user_id: nil, gdpr_anonymized: true)
  
  # Delete personal data
  whatsapp_messages.destroy_all
  conversations.destroy_all
  clients.destroy_all
  
  # Anonymize user record
  update!(
    phone_number: "DELETED_#{id}",
    company_name: "DELETED",
    address: nil,
    vat_number: nil,
    magic_link_token_digest: nil,
    stripe_customer_id: nil
  )
end
```

### Retention Policies

- **WhatsApp Messages:** 1 year (then auto-delete)
- **Conversations:** 1 year (then auto-delete)
- **Quotes/Invoices:** 10 years (legal requirement)
- **Subscription Invoices:** 10 years (legal requirement)
- **System Logs:** 1 year
- **Audio Files:** Delete after transcription
- **Magic Links:** 90 days (then expire)

---

## Migration Path

### From Current State to Bot-First

```ruby
# db/migrate/20250115_migrate_to_bot_first.rb

class MigrateToBotFirst < ActiveRecord::Migration[7.1]
  def up
    # If users already exist with emails
    if column_exists?(:users, :email)
      # Keep existing users, add phone requirement
      add_column :users, :phone_number, :string
      add_index :users, :phone_number, unique: true
      
      # Make email optional
      change_column_null :users, :email, true
      
      # Add magic link fields
      add_column :users, :magic_link_token_digest, :string
      add_column :users, :magic_link_token_prefix, :string, limit: 16
      add_column :users, :magic_link_expires_at, :datetime
      add_column :users, :magic_link_last_used_at, :datetime
      add_column :users, :magic_link_sent, :boolean, default: false
      add_index :users, :magic_link_token_prefix
      
      # Activity tracking
      add_column :users, :first_message_at, :datetime
      add_column :users, :last_activity_at, :datetime
      add_column :users, :last_login_ip, :string
      add_column :users, :last_login_at, :datetime
      add_column :users, :onboarding_completed, :boolean, default: true
      
      # Unipile
      add_column :users, :unipile_chat_id, :string
      add_column :users, :unipile_attendee_id, :string
      add_index :users, :unipile_chat_id
      add_index :users, :unipile_attendee_id
      
      # Subscription
      add_column :users, :subscription_status, :string, default: 'active'
      add_index :users, :subscription_status
    else
      # Fresh install - create table properly
      create_table :users do |t|
        # Identity
        t.string :phone_number, null: false, index: { unique: true }
        
        # Magic Link
        t.string :magic_link_token_digest
        t.string :magic_link_token_prefix, limit: 16, index: true
        t.datetime :magic_link_expires_at
        t.datetime :magic_link_last_used_at
        t.boolean :magic_link_sent, default: false
        
        # Company Info
        t.string :company_name
        t.string :siret, index: true
        t.text :address
        t.string :vat_number
        
        # Settings
        t.string :preferred_language, default: 'fr'
        
        # Stripe
        t.string :stripe_customer_id, index: true
        t.string :subscription_status, default: 'trialing', index: true
        
        # Unipile
        t.string :unipile_chat_id, index: true
        t.string :unipile_attendee_id, index: true
        
        # Activity
        t.boolean :onboarding_completed, default: false
        t.datetime :first_message_at
        t.datetime :last_activity_at
        t.datetime :last_login_ip
        t.datetime :last_login_at
        
        t.timestamps
      end
    end
  end
  
  def down
    # Revert if needed
  end
end
```

---

## Testing Strategy

### Magic Link Security Tests

```ruby
# spec/models/user_spec.rb

describe User do
  describe '#generate_magic_link!' do
    it 'creates a cryptographically secure token' do
      user = create(:user)
      token = user.generate_magic_link!
      
      expect(token).to be_present
      expect(token.length).to be >= 40 # URL-safe base64
      expect(user.magic_link_token_digest).to be_present
      expect(user.magic_link_expires_at).to be > Time.current
    end
    
    it 'never stores token in plain text' do
      user = create(:user)
      token = user.generate_magic_link!
      
      user.reload
      
      # Token should not be findable in database
      expect(user.attributes.values.join).not_to include(token)
    end
  end
  
  describe '#valid_magic_link?' do
    it 'validates correct token' do
      user = create(:user)
      token = user.generate_magic_link!
      
      expect(user.valid_magic_link?(token)).to be true
    end
    
    it 'rejects incorrect token' do
      user = create(:user)
      user.generate_magic_link!
      
      expect(user.valid_magic_link?('wrong-token')).to be false
    end
    
    it 'rejects expired token' do
      user = create(:user)
      token = user.generate_magic_link!
      
      travel_to 91.days.from_now do
        expect(user.valid_magic_link?(token)).to be false
      end
    end
  end
end
```

### User Auto-Creation Tests

```ruby
# spec/services/whatsapp_bot/user_creator_spec.rb

describe WhatsappBot::UserCreator do
  it 'creates user from phone number' do
    expect {
      described_class.call(
        phone_number: '+33612345678',
        unipile_chat_id: 'chat_123',
        unipile_attendee_id: 'att_456'
      )
    }.to change(User, :count).by(1)
    
    user = User.last
    expect(user.phone_number).to eq('+33612345678')
    expect(user.subscription_status).to eq('trialing')
    expect(user.first_message_at).to be_present
  end
  
  it 'does not duplicate existing user' do
    existing = create(:user, phone_number: '+33612345678')
    
    expect {
      described_class.call(
        phone_number: '+33612345678',
        unipile_chat_id: 'chat_789',
        unipile_attendee_id: 'att_012'
      )
    }.not_to change(User, :count)
    
    existing.reload
    expect(existing.unipile_chat_id).to eq('chat_789') # Updated
  end
end
```

---

## Performance Considerations

### Database Queries

**Slow (Avoid):**
```ruby
# Finding user by magic link - checking ALL users
User.all.find { |u| u.valid_magic_link?(token) }
# O(n) where n = number of users
```

**Fast (Use):**
```ruby
# Using prefix index
candidates = User.where(magic_link_token_prefix: token[0..15])
user = candidates.find { |u| u.valid_magic_link?(token) }
# O(1) database lookup + O(m) bcrypt checks where m = ~1-2 users
```

### Caching Strategy

```ruby
# Cache user session data
Rails.cache.fetch("user_session_#{user.id}", expires_in: 1.hour) do
  {
    id: user.id,
    phone: user.phone_number,
    company: user.company_name,
    subscription_active: user.active_subscription?
  }
end

# Cache document counts for dashboard
Rails.cache.fetch("user_stats_#{user.id}", expires_in: 5.minutes) do
  {
    quotes_count: user.quotes.count,
    invoices_count: user.invoices.count,
    clients_count: user.clients.count
  }
end
```

---

## Conclusion

Cette architecture **bot-first avec magic links** offre:

✅ **Simplicité extrême** - Pas de mots de passe, pas d'inscription web
✅ **Sécurité robuste** - Tokens cryptographiques, expiration, rate limiting
✅ **UX parfaite** - L'utilisateur ne fait rien, tout est automatique
✅ **Admin-friendly** - Visibilité complète par numéro de téléphone
✅ **Scalable** - Architecture propre et performante

C'est l'approche idéale pour une application WhatsApp-first.
