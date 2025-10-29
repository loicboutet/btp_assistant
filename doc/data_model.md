# Data Model

## Overview

This document describes all the objects (models) of the application and their relationships, with proper integration with Unipile's WhatsApp messaging API.

## Core Models

### User (Artisan/Entrepreneur)

The main user of the application - the construction entrepreneur.

**Attributes:**
- `id` (primary key)
- `email` (string, unique, required)
- `first_name` (string, required)
- `last_name` (string, required)
- `whatsapp_phone` (string, unique, required) - Format: +33600000000
- `company_name` (string, required)
- `siret` (string, unique, required)
- `address` (text, required)
- `vat_number` (string, optional)
- `preferred_language` (enum: 'fr', 'tr', required)
- `whatsapp_connected` (boolean, default: false)
- `unipile_account_id` (string, optional) - Unipile Account ID from Unipile API
- `unipile_connection_params` (json, optional) - Stores Unipile connection metadata (phone_number, etc.)
- `account_status` (enum: 'active', 'suspended', 'pending', default: 'pending')
- `stripe_customer_id` (string, optional)
- `timestamps` (created_at, updated_at)

**Relationships:**
- has_many :subscriptions
- has_many :clients
- has_many :quotes
- has_many :invoices
- has_many :conversations
- has_many :subscription_invoices
- has_many :whatsapp_chats

**Unipile Integration:**
- `unipile_account_id` maps to Unipile's Account object (type: WHATSAPP)
- Connection established via QR code authentication
- One account = One WhatsApp number = One SIRET

---

### WhatsappChat

Represents a WhatsApp chat/conversation from Unipile. Maps to Unipile's Chat object.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `unipile_chat_id` (string, unique, required) - Unipile's chat ID
- `unipile_provider_id` (string, required) - Unipile's provider chat ID
- `attendee_provider_id` (string, required) - WhatsApp attendee ID (phone number format)
- `attendee_name` (string, optional) - Contact name from WhatsApp
- `chat_type` (integer, required) - 0: individual, 1: group, 2: broadcast
- `last_message_at` (datetime, optional)
- `unread_count` (integer, default: 0)
- `archived` (boolean, default: false)
- `muted_until` (datetime, optional)
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- has_many :whatsapp_messages
- has_one :conversation (optional) - Links to active conversation if exists

**Unipile Integration:**
- Synced from Unipile's `GET /api/v1/chats` endpoint
- Updated via Unipile webhook: `message_received`, `message_sent`
- `attendee_provider_id` format: `33600000000@s.whatsapp.net` (Unipile format)

---

### WhatsappMessage

Represents individual WhatsApp messages from Unipile. Maps to Unipile's Message object.

**Attributes:**
- `id` (primary key)
- `whatsapp_chat_id` (foreign key, required)
- `user_id` (foreign key, required)
- `conversation_id` (foreign key, optional) - Links to conversation if part of workflow
- `unipile_message_id` (string, unique, required) - Unipile's message ID
- `unipile_provider_id` (string, required) - Provider's message ID
- `direction` (enum: 'inbound', 'outbound', required)
- `message_type` (enum: 'text', 'audio', 'image', 'document', 'video', required)
- `text_content` (text, optional) - Text content or transcription
- `sender_id` (string, required) - Unipile sender_id
- `sender_name` (string, optional)
- `attachments` (json, optional) - Array of attachment metadata from Unipile
- `audio_transcription` (text, optional) - Whisper API transcription result
- `detected_language` (string, optional) - Language detected by Whisper
- `quote_message_id` (string, optional) - If replying to another message (Unipile quote_id)
- `sent_at` (datetime, required)
- `delivered_at` (datetime, optional)
- `read_at` (datetime, optional)
- `processed` (boolean, default: false) - If processed by AI/workflow
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :whatsapp_chat
- belongs_to :user
- belongs_to :conversation (optional)

**Unipile Integration:**
- Created from webhook payload: `message_received` event
- Sent via `POST /api/v1/chats/{chat_id}/messages`
- Audio attachments downloaded via `GET /api/v1/messages/{message_id}/attachments/{attachment_id}`
- `attachments` structure follows Unipile's attachment schema

---

### Client (End Customer)

The artisan's customers for whom quotes and invoices are created.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `whatsapp_chat_id` (foreign key, optional) - Link to WhatsApp chat if client contacted via WhatsApp
- `name` (string, required)
- `address` (text, required)
- `siret` (string, optional) - If professional client
- `contact_phone` (string, optional)
- `contact_email` (string, optional)
- `created_via` (enum: 'whatsapp', 'web', 'admin', default: 'whatsapp')
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- belongs_to :whatsapp_chat (optional)
- has_many :quotes
- has_many :invoices

**Business Logic:**
- Can be created via WhatsApp conversation (guided workflow)
- Linked to WhatsApp chat for context
- One client can have multiple WhatsApp chats (different phone numbers)

---

### Quote (Devis)

Commercial quotes created by artisans for their clients.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `client_id` (foreign key, required)
- `conversation_id` (foreign key, optional) - Link to conversation that created this quote
- `quote_number` (string, unique, required) - Auto-generated: DEVIS-YYYY-NNNN
- `issue_date` (date, required)
- `validity_date` (date, optional)
- `status` (enum: 'draft', 'sent', 'accepted', 'rejected', default: 'draft')
- `subtotal_amount` (decimal, required)
- `vat_rate` (decimal, default: 20.0)
- `vat_amount` (decimal, required)
- `total_amount` (decimal, required)
- `notes` (text, optional)
- `pdf_url` (string, optional) - Path to generated PDF
- `sent_via_whatsapp_at` (datetime, optional) - When PDF was sent via WhatsApp
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- belongs_to :client
- belongs_to :conversation (optional)
- has_many :quote_items (dependent: :destroy)
- has_many :invoices

**Business Logic:**
- Created via WhatsApp conversational workflow
- PDF generated and sent directly on WhatsApp
- Auto-generates quote number per user per year

---

### QuoteItem (Line Item for Quote)

Individual service lines within a quote.

**Attributes:**
- `id` (primary key)
- `quote_id` (foreign key, required)
- `description` (text, required)
- `quantity` (decimal, required)
- `unit_price` (decimal, required)
- `total_price` (decimal, required) - Calculated: quantity * unit_price
- `position` (integer, default: 0) - For ordering items
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :quote

---

### Invoice (Facture)

Invoices created by artisans for their clients.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `client_id` (foreign key, required)
- `quote_id` (foreign key, optional) - Link to quote if invoice is based on one
- `conversation_id` (foreign key, optional) - Link to conversation that created this invoice
- `invoice_number` (string, unique, required) - Auto-generated: FACT-YYYY-NNNN
- `issue_date` (date, required)
- `due_date` (date, optional)
- `status` (enum: 'draft', 'sent', 'paid', 'overdue', default: 'draft')
- `subtotal_amount` (decimal, required)
- `vat_rate` (decimal, default: 20.0)
- `vat_amount` (decimal, required)
- `total_amount` (decimal, required)
- `notes` (text, optional)
- `pdf_url` (string, optional) - Path to generated PDF
- `sent_via_whatsapp_at` (datetime, optional) - When PDF was sent via WhatsApp
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- belongs_to :client
- belongs_to :quote (optional)
- belongs_to :conversation (optional)
- has_many :invoice_items (dependent: :destroy)

**Business Logic:**
- Can be linked to an existing quote or created independently
- Created via WhatsApp conversational workflow
- PDF generated and sent directly on WhatsApp

---

### InvoiceItem (Line Item for Invoice)

Individual service lines within an invoice.

**Attributes:**
- `id` (primary key)
- `invoice_id` (foreign key, required)
- `description` (text, required)
- `quantity` (decimal, required)
- `unit_price` (decimal, required)
- `total_price` (decimal, required) - Calculated: quantity * unit_price
- `position` (integer, default: 0) - For ordering items
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :invoice

---

### Subscription

User's monthly subscription to the service.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `stripe_subscription_id` (string, unique, required)
- `status` (enum: 'active', 'past_due', 'canceled', 'trialing', required)
- `current_period_start` (datetime, required)
- `current_period_end` (datetime, required)
- `cancel_at_period_end` (boolean, default: false)
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- has_many :subscription_invoices

---

### SubscriptionInvoice

Monthly subscription invoices automatically generated.

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
- `pdf_url` (string, optional)
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- belongs_to :subscription

---

### Conversation

Tracks WhatsApp conversation workflows for document creation. Represents a state machine for guided conversational flows.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, required)
- `whatsapp_chat_id` (foreign key, required) - Link to WhatsApp chat
- `conversation_type` (enum: 'quote_creation', 'invoice_creation', 'client_creation', 'general', required)
- `status` (enum: 'active', 'completed', 'abandoned', 'error', default: 'active')
- `current_step` (string, optional) - Current step in the workflow state machine
- `context_data` (json, optional) - Stores workflow state and collected data
- `language` (enum: 'fr', 'tr', required) - Detected language for this conversation
- `started_at` (datetime, required)
- `completed_at` (datetime, optional)
- `last_interaction_at` (datetime, required) - For abandoned conversation detection
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user
- belongs_to :whatsapp_chat
- has_many :whatsapp_messages
- belongs_to :quote (optional) - If conversation created a quote
- belongs_to :invoice (optional) - If conversation created an invoice
- belongs_to :client (optional) - If conversation created a client

**Business Logic:**
- One active conversation per chat at a time
- Workflow state machine tracks progress through document creation
- Context data stores partial information during multi-step flows
- Abandoned if no interaction for 30 minutes

---

### SystemLog

Audit trail and system logs for admin monitoring.

**Attributes:**
- `id` (primary key)
- `user_id` (foreign key, optional) - Null for system-wide events
- `log_type` (enum: 'info', 'warning', 'error', 'audit', required)
- `event` (string, required) - Event name (e.g., 'whatsapp.message_received', 'pdf.generated')
- `description` (text, optional)
- `metadata` (json, optional) - Additional context (Unipile IDs, error details, etc.)
- `ip_address` (string, optional)
- `timestamps` (created_at, updated_at)

**Relationships:**
- belongs_to :user (optional)

---

## Relationship Diagram

```
User (Artisan)
├── unipile_account_id → Unipile Account (WHATSAPP)
│
├── has_many :whatsapp_chats
│   └── WhatsappChat (Unipile Chat object)
│       ├── has_many :whatsapp_messages
│       │   └── WhatsappMessage (Unipile Message object)
│       │       └── belongs_to :conversation (optional)
│       │
│       └── has_one :conversation (active)
│
├── has_many :conversations
│   └── Conversation (Workflow State Machine)
│       ├── belongs_to :whatsapp_chat
│       ├── has_many :whatsapp_messages
│       └── can create: Quote, Invoice, or Client
│
├── has_many :clients
│   └── Client
│       ├── belongs_to :whatsapp_chat (optional)
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
├── has_many :subscriptions
│   └── Subscription
│       └── has_many :subscription_invoices
│           └── SubscriptionInvoice
│
└── has_many :system_logs
    └── SystemLog
```

## Unipile Integration Details

### WhatsApp Account Connection Flow

1. **Initial Connection**
   - `POST /api/v1/accounts` with `provider: 'WHATSAPP'`
   - Returns QR code for scanning
   - User scans QR with their WhatsApp
   - Unipile returns `account_id` → stored as `User.unipile_account_id`

2. **Account Metadata**
   - Connection params stored in `User.unipile_connection_params`:
     ```json
     {
       "im": {
         "phone_number": "+33600000000"
       }
     }
     ```

### Webhook Integration

Configure webhook in Unipile for real-time message reception:

**Webhook URL:** `https://your-app.com/webhooks/unipile/messages`

**Webhook Payload Structure:**
```json
{
  "account_id": "unipile_account_id",
  "account_type": "WHATSAPP",
  "event": "message_received",
  "chat_id": "R8J-xM9WX7eoHLp6gSVtWQ",
  "message_id": "ykmhfXlRW0W_cqReJYrfBw",
  "message": "Hello World !",
  "sender": {
    "attendee_id": "C8zaRZTlVcmfnke_Vai4Gg",
    "attendee_name": "John Doe",
    "attendee_provider_id": "33600000000@s.whatsapp.net"
  },
  "timestamp": "2023-09-24T13:49:07.965Z",
  "attachments": [
    {
      "id": "attachment_id",
      "type": "audio",
      "mimetype": "audio/ogg",
      "url": "att://base64_encoded_attachment_ref"
    }
  ]
}
```

### Message Handling Flow

1. **Receiving Messages**
   - Webhook receives `message_received` event
   - Create/update `WhatsappChat` from `chat_id`
   - Create `WhatsappMessage` from payload
   - Detect if part of active `Conversation`
   - Process through AI/workflow if needed

2. **Sending Messages**
   - Use `POST /api/v1/chats/{chat_id}/messages`
   - Parameters:
     ```json
     {
       "text": "Response text",
       "attachments": ["file_binary"],
       "typing_duration": "2000"
     }
     ```

3. **Audio Message Processing**
   - Download audio: `GET /api/v1/messages/{message_id}/attachments/{attachment_id}`
   - Transcribe with Whisper API
   - Store transcription in `WhatsappMessage.audio_transcription`
   - Detect language and process with GPT-4

### Unipile Data Mapping

| Our Model | Unipile Field | Type | Notes |
|-----------|--------------|------|-------|
| `User.unipile_account_id` | `account.id` | string | Account ID from Unipile |
| `WhatsappChat.unipile_chat_id` | `chat.id` | string | Unipile's internal chat ID |
| `WhatsappChat.unipile_provider_id` | `chat.provider_id` | string | WhatsApp's chat ID |
| `WhatsappChat.attendee_provider_id` | `chat.attendee_provider_id` | string | Format: `33600000000@s.whatsapp.net` |
| `WhatsappMessage.unipile_message_id` | `message.id` | string | Unipile's message ID |
| `WhatsappMessage.sender_id` | `sender.attendee_id` | string | Unipile attendee ID |
| `WhatsappMessage.attachments` | `message.attachments` | json | Array of attachment objects |

## Key Business Rules

### Document Numbering
- Quotes: Format `DEVIS-YYYY-NNNN` (e.g., DEVIS-2024-0001)
- Invoices: Format `FACT-YYYY-NNNN` (e.g., FACT-2024-0001)
- Subscription Invoices: Format `ABO-YYYY-NNNN` (e.g., ABO-2024-0001)
- Numbers are sequential per user per year

### VAT Calculation
- Default VAT rate: 20%
- Can be configured per user
- Calculation: `vat_amount = subtotal_amount * (vat_rate / 100)`
- Total: `total_amount = subtotal_amount + vat_amount`

### Account Status Flow
1. **pending**: After registration, before payment confirmation
2. **active**: After successful payment and WhatsApp connection, can use all features
3. **suspended**: After failed payment or admin action

### Subscription Status
- **trialing**: During trial period (if implemented)
- **active**: Subscription is active and paid
- **past_due**: Payment failed, grace period
- **canceled**: User canceled subscription

### Conversation Workflow States

Each conversation type implements a state machine pattern:

**Quote Creation Workflow:**
1. `initiated` - User triggers quote creation
2. `select_or_create_client` - Ask for client or create new
3. `confirm_client` - Confirm client selection
4. `add_line_items` - Collect service lines (loop)
5. `confirm_line_item` - Confirm each line item
6. `review_items` - Show all items for review
7. `calculate_totals` - Calculate VAT and totals
8. `review_total` - Present final amounts for approval
9. `generate_pdf` - Generate PDF document
10. `send_pdf` - Send PDF via WhatsApp
11. `completed` - Mark as completed

**Invoice Creation Workflow:**
1. `initiated` - User triggers invoice creation
2. `link_to_quote_or_independent` - Ask if based on quote
3. `select_quote` - If yes, select existing quote
4. `select_or_create_client` - Ask for client or create new
5. `confirm_client` - Confirm client selection
6. `add_line_items` - Collect service lines (loop)
7. `confirm_line_item` - Confirm each line item
8. `review_items` - Show all items for review
9. `calculate_totals` - Calculate VAT and totals
10. `review_total` - Present final amounts for approval
11. `generate_pdf` - Generate PDF document
12. `send_pdf` - Send PDF via WhatsApp
13. `completed` - Mark as completed

**Client Creation Workflow:**
1. `initiated` - User triggers client creation
2. `collect_name` - Ask for client name
3. `confirm_name` - Confirm name
4. `collect_address` - Ask for address
5. `confirm_address` - Confirm address
6. `collect_siret` - Ask if professional (SIRET)
7. `confirm_siret` - Confirm SIRET if provided
8. `collect_contacts` - Ask for phone/email
9. `confirm_contacts` - Confirm contact info
10. `review_client` - Show all client info
11. `save_client` - Save to database
12. `completed` - Mark as completed

### Conversation Context Data Structure

The `context_data` JSON field stores workflow state:

```json
{
  "client": {
    "id": 123,
    "name": "Entreprise Dubois",
    "confirmed": true
  },
  "items": [
    {
      "description": "Maçonnerie mur extérieur",
      "quantity": 50.0,
      "unit_price": 85.0,
      "confirmed": true
    }
  ],
  "totals": {
    "subtotal": 4250.0,
    "vat_rate": 20.0,
    "vat_amount": 850.0,
    "total": 5100.0
  },
  "last_gpt_response": "J'ai bien noté...",
  "retry_count": 0
}
```

## Indexes

### Performance Indexes
- `users`: `email`, `siret`, `whatsapp_phone`, `stripe_customer_id`, `unipile_account_id`
- `whatsapp_chats`: `user_id`, `unipile_chat_id`, `unipile_provider_id`, `attendee_provider_id`
- `whatsapp_messages`: `whatsapp_chat_id`, `user_id`, `unipile_message_id`, `conversation_id`, `direction`, `sent_at`
- `clients`: `user_id`, `whatsapp_chat_id`, `siret`
- `quotes`: `user_id`, `client_id`, `conversation_id`, `quote_number`, `status`, `issue_date`
- `invoices`: `user_id`, `client_id`, `quote_id`, `conversation_id`, `invoice_number`, `status`, `issue_date`
- `subscriptions`: `user_id`, `stripe_subscription_id`, `status`
- `conversations`: `user_id`, `whatsapp_chat_id`, `status`, `conversation_type`, `last_interaction_at`

### Composite Indexes
- `whatsapp_messages`: `(whatsapp_chat_id, sent_at DESC)` - For chat history
- `conversations`: `(whatsapp_chat_id, status)` - For finding active conversations
- `quotes`: `(user_id, issue_date DESC)` - For user's recent quotes
- `invoices`: `(user_id, issue_date DESC)` - For user's recent invoices

## External Service Integrations

### Stripe
- `User.stripe_customer_id` → Stripe Customer ID
- `Subscription.stripe_subscription_id` → Stripe Subscription ID
- `SubscriptionInvoice.stripe_invoice_id` → Stripe Invoice ID
- Webhook: Handle `invoice.payment_succeeded`, `invoice.payment_failed`

### Unipile (WhatsApp)
- **Base URL:** `https://{YOUR_DSN}/api/v1/`
- **Authentication:** `X-API-KEY` header
- **Connection:** `User.unipile_account_id` → Unipile Account object
- **Chat Sync:** `WhatsappChat.unipile_chat_id` → Unipile Chat object
- **Message Sync:** `WhatsappMessage.unipile_message_id` → Unipile Message object
- **Webhook:** Real-time message reception at `/webhooks/unipile/messages`

### OpenAI
- **Whisper API:** Audio transcription
  - Input: Audio file from Unipile attachment
  - Output: Transcription text + detected language
  - Stored in: `WhatsappMessage.audio_transcription`, `detected_language`
  
- **GPT-4 API:** Conversational AI
  - Input: User message + conversation context
  - Output: Response text + extracted structured data
  - System prompt includes: language, workflow state, context data
  - Streaming responses for better UX

## Storage

### File Storage (Active Storage)
- **Quote PDFs:** `storage/quotes/:user_id/:year/:quote_number.pdf`
- **Invoice PDFs:** `storage/invoices/:user_id/:year/:invoice_number.pdf`
- **Subscription Invoice PDFs:** `storage/subscription_invoices/:user_id/:year/:invoice_number.pdf`
- **Audio files:** `storage/audio/:user_id/:conversation_id/:message_id.ogg` (temporary)
- **Attachment cache:** `storage/whatsapp_attachments/:user_id/:message_id/:attachment_id` (temporary)

### File Upload to WhatsApp
When sending PDFs via WhatsApp:
1. Generate PDF and store locally
2. Send via Unipile: `POST /api/v1/chats/{chat_id}/messages` with `attachments` as binary
3. Update record with `sent_via_whatsapp_at` timestamp
4. Max file size: 15MB (Unipile limit)

## Data Retention

- **WhatsApp Messages:** Keep for 1 year (configurable per legal requirements)
- **WhatsApp Chats:** Keep indefinitely (for client history)
- **Conversations:** Keep indefinitely (for audit trail)
- **Quotes/Invoices:** Keep for 10 years (legal requirement in France)
- **System Logs:** Keep for 1 year
- **Audio files:** Delete after transcription (or keep for 30 days max)
- **Attachment cache:** Delete after 7 days

## Sync Strategy

### Initial Sync (Account Setup)
1. User connects WhatsApp via QR code
2. Sync last 100 chats: `GET /api/v1/chats?limit=100`
3. For each chat, sync last 50 messages: `GET /api/v1/chats/{chat_id}/messages?limit=50`
4. Mark user as `whatsapp_connected: true`

### Real-time Sync (Webhook)
1. Receive webhook event: `message_received`, `message_sent`
2. Upsert `WhatsappChat` from payload
3. Create `WhatsappMessage` from payload
4. Process message through AI workflow if needed
5. Send response via Unipile API

### Periodic Sync (Fallback)
- Run every 5 minutes for users with `whatsapp_connected: true`
- Fetch messages since last sync: `GET /api/v1/chats?after={last_sync_time}`
- Handle messages missed by webhook (network issues, etc.)

## Error Handling

### Unipile API Errors
- **401 Unauthorized:** WhatsApp account disconnected → Set `whatsapp_connected: false`, notify user
- **errors/disconnected_account:** Reconnection required → Trigger QR code flow
- **errors/multiple_sessions:** Another session detected → Log warning, continue
- **504 Gateway Timeout:** Retry with exponential backoff

### Conversation Errors
- **Timeout (30min no response):** Mark conversation as `abandoned`
- **Invalid input (3 retries):** Offer to restart workflow or contact support
- **GPT-4 API error:** Fallback to predefined responses, log error
- **PDF generation failure:** Retry once, then mark as error and notify admin

## Security Considerations

### Data Protection
- **Unipile API Key:** Store in encrypted environment variables
- **Stripe API Key:** Store in encrypted environment variables
- **OpenAI API Key:** Store in encrypted environment variables
- **User WhatsApp Data:** Encrypted at rest in database
- **PDF Files:** Secure storage with signed URLs (24h expiry)
- **Audio Files:** Delete after transcription, never persist long-term

### Access Control
- Users can only access their own WhatsApp chats/messages
- Admin dashboard: Separate authentication, audit logs
- Webhook endpoints: Verify Unipile signature/token
- API rate limiting: Per user, per endpoint

### GDPR Compliance
- User data export: Include all WhatsApp messages, conversations, documents
- User data deletion: Cascade delete with Unipile account disconnection
- Data retention policies: Configurable per legal requirements
- Audit trail: All data access logged in SystemLog
