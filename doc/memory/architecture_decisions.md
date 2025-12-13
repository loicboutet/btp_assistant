# Architecture Decisions - BTP WhatsApp Assistant

## Final Decisions (Confirmed)

### 1. Audio Message Handling
**Decision:** Whisper transcription first, then text to GPT-4
- More reliable
- Can log transcription
- Easier to debug

### 2. Conversation Context Window
**Decision:** Last 10-15 messages OR messages from last 2 hours (whichever is smaller)
- Keeps context relevant
- Controls costs
- Prevents confusion from old context

### 3. Multi-step Tool Calls
**Decision:** Option B - One tool at a time
- Execute one tool
- Send result back to GPT-4
- Let GPT-4 decide next step
- More controllable, easier to debug

### 4. PDF Sending
**Decision:** Auto-send after creation
- User asks for quote → receives it immediately
- Add `send_quote_pdf(quote_id)` / `send_invoice_pdf(invoice_id)` tools for re-sending

### 5. Error Handling in Tools
**Decision:** Return structured error to GPT-4
```ruby
{ success: false, error: "SIRET invalide", field: "siret" }
```
GPT-4 handles the conversation naturally, asks user to correct.

### 6. Onboarding Flow
**Decision:** Handle in system prompt + `update_user_info` tool
- No special onboarding tool
- System prompt instructs GPT-4 to collect info from new users
- Natural conversation flow

### 7. Rate Limiting
**Decision:** Soft limit (50 messages/hour/user)
- Log warnings, don't block
- These are paying customers
- Monitor for abuse manually

### 8. Subscription Status
**Decision:** NO TRIAL PERIOD
- New user → Collect info → Send payment link
- `active`: Full access
- `past_due`: Warn, allow with grace period
- `canceled`: Block creation, allow viewing, send payment link

Flow for new users:
```
1. First message received
2. User auto-created (subscription_status: 'pending')
3. Bot collects company info (name, SIRET, address)
4. Bot sends Stripe payment link
5. After payment → subscription_status: 'active'
6. User can now create quotes/invoices
```

### 9. Admin Testing
**Decision:** Add "Test conversation" feature in admin
- Send test message as specific user
- See LLM response without actually sending
- Useful for debugging prompts

### 10. Webhook Retry Handling
**Decision:** Check `unipile_message_id` uniqueness
- Skip processing if message already exists
- Prevents duplicate processing on retries

---

## Business Rules

### Document Numbering
**Decision:** Sequential numbering with NO GAPS, scoped by user

```ruby
# Quote: DEVIS-2025-0001, DEVIS-2025-0002, ...
# Invoice: FACT-2025-0001, FACT-2025-0002, ...

# Scoped per user, per year
# User A: DEVIS-2025-0001
# User B: DEVIS-2025-0001 (separate sequence)
```

Implementation:
```ruby
class Quote < ApplicationRecord
  before_create :assign_quote_number
  
  private
  
  def assign_quote_number
    year = issue_date.year
    last_quote = user.quotes
                     .where("EXTRACT(YEAR FROM issue_date) = ?", year)
                     .order(quote_number: :desc)
                     .first
    
    last_num = last_quote&.quote_number&.split('-')&.last&.to_i || 0
    self.quote_number = "DEVIS-#{year}-#{(last_num + 1).to_s.rjust(4, '0')}"
  end
end
```

### Quote to Invoice Conversion
**Decision:** NOT in scope for this version
- Create invoices independently
- No automatic item copying from quotes
- Can be added later if needed

### VAT Handling
**Decision:** Default VAT rate (20%) but user can specify
- Store `vat_rate` on each quote/invoice
- Default to 20%
- User can say "TVA à 10%" and LLM updates accordingly
- Tool parameter: `vat_rate` (optional, defaults to 20)

---

## Subscription Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      NEW USER FLOW                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. User sends first WhatsApp message                           │
│           │                                                      │
│           ▼                                                      │
│  2. System creates User with:                                   │
│     - phone_number (from WhatsApp)                              │
│     - subscription_status: 'pending'                            │
│           │                                                      │
│           ▼                                                      │
│  3. GPT-4 detects new user (no company_name)                    │
│     Bot: "Bienvenue! Je suis votre assistant..."                │
│     Bot: "Pour commencer, quel est le nom de votre entreprise?" │
│           │                                                      │
│           ▼                                                      │
│  4. Collect info via conversation:                              │
│     - company_name                                               │
│     - siret                                                      │
│     - address                                                    │
│     → Calls update_user_info tool                               │
│           │                                                      │
│           ▼                                                      │
│  5. GPT-4 calls send_payment_link tool                          │
│     Bot: "Pour activer votre compte, veuillez procéder          │
│           au paiement: [Stripe link]"                           │
│           │                                                      │
│           ▼                                                      │
│  6. User pays via Stripe                                        │
│           │                                                      │
│           ▼                                                      │
│  7. Stripe webhook → subscription_status: 'active'              │
│           │                                                      │
│           ▼                                                      │
│  8. User can now create quotes/invoices                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Subscription Statuses

| Status | Meaning | Allowed Actions |
|--------|---------|-----------------|
| `pending` | New user, hasn't paid yet | View only, collect info, receive payment link |
| `active` | Paid, subscription current | Full access |
| `past_due` | Payment failed, grace period | Full access with warning |
| `canceled` | Subscription ended | View only, receive payment link |

---

## Tool Execution Flow (Option B)

```
User: "Crée un devis pour Dupont, maçonnerie 50m² à 80€"
           │
           ▼
GPT-4 Response #1:
  tool_call: search_clients(query: "Dupont")
           │
           ▼
Execute tool → Returns: []  (no results)
           │
           ▼
Send tool result back to GPT-4
           │
           ▼
GPT-4 Response #2:
  content: "Je ne trouve pas de client Dupont. 
            Voulez-vous le créer? J'ai besoin de son adresse."
           │
           ▼
Send message to user via WhatsApp
           │
           ▼
User: "Oui, 12 rue de la Paix Paris"
           │
           ▼
GPT-4 Response #3:
  tool_call: create_client(name: "Dupont", address: "12 rue de la Paix Paris")
           │
           ▼
Execute tool → Returns: { success: true, client_id: 42 }
           │
           ▼
Send tool result back to GPT-4
           │
           ▼
GPT-4 Response #4:
  tool_call: create_quote(client_id: 42, items: [{description: "Maçonnerie", quantity: 50, unit_price: 80}])
           │
           ▼
Execute tool → Creates quote, generates PDF, sends via WhatsApp
           │
           ▼
Returns: { success: true, quote_number: "DEVIS-2025-0001", total: 4800.00 }
           │
           ▼
Send tool result back to GPT-4
           │
           ▼
GPT-4 Response #5:
  content: "Devis DEVIS-2025-0001 créé pour Dupont!
            Total: 4 800,00 € TTC
            Je vous l'ai envoyé."
           │
           ▼
Send message to user via WhatsApp
```

---

## Updated Tools List

```ruby
TOOLS = [
  # Client management
  :search_clients,      # Search by name
  :create_client,       # Create new client
  
  # Quote management  
  :create_quote,        # Create quote (auto-sends PDF)
  :list_recent_quotes,  # List user's quotes
  :send_quote_pdf,      # Re-send quote PDF
  
  # Invoice management
  :create_invoice,      # Create invoice (auto-sends PDF)
  :list_recent_invoices,# List user's invoices
  :send_invoice_pdf,    # Re-send invoice PDF
  :mark_invoice_paid,   # Mark invoice as paid
  
  # User management
  :get_user_info,       # Get company info
  :update_user_info,    # Update company info
  
  # Access & Payment
  :send_web_link,       # Send signed URL for web access
  :send_payment_link,   # Send Stripe payment link (for pending/canceled users)
]
```

---

## File Structure

```
app/
├── controllers/
│   ├── admin/
│   │   ├── dashboard_controller.rb
│   │   ├── users_controller.rb
│   │   ├── settings_controller.rb
│   │   ├── prompts_controller.rb
│   │   └── conversations_controller.rb  # View WhatsApp logs
│   ├── client/
│   │   ├── dashboard_controller.rb
│   │   ├── quotes_controller.rb
│   │   ├── invoices_controller.rb
│   │   └── clients_controller.rb
│   ├── webhooks/
│   │   ├── unipile_controller.rb
│   │   └── stripe_controller.rb
│   └── user_sessions_controller.rb
│
├── models/
│   ├── admin.rb
│   ├── app_setting.rb
│   ├── user.rb
│   ├── client.rb
│   ├── quote.rb
│   ├── quote_item.rb
│   ├── invoice.rb
│   ├── invoice_item.rb
│   ├── whatsapp_message.rb
│   ├── llm_conversation.rb
│   ├── llm_prompt.rb
│   ├── subscription.rb
│   ├── subscription_invoice.rb
│   └── system_log.rb
│
├── services/
│   ├── signed_url_service.rb
│   ├── unipile_client.rb
│   ├── openai_client.rb
│   ├── stripe_service.rb
│   ├── whatsapp_bot/
│   │   ├── conversation_engine.rb
│   │   ├── message_processor.rb
│   │   └── audio_transcriber.rb
│   ├── llm_tools/
│   │   ├── base_tool.rb
│   │   ├── executor.rb
│   │   ├── tool_definitions.rb
│   │   ├── search_clients.rb
│   │   ├── create_client.rb
│   │   ├── create_quote.rb
│   │   ├── create_invoice.rb
│   │   ├── send_web_link.rb
│   │   ├── send_payment_link.rb
│   │   └── ... (other tools)
│   └── pdf_generators/
│       ├── quote_pdf.rb
│       └── invoice_pdf.rb
│
├── jobs/
│   └── process_whatsapp_message_job.rb
│
└── views/
    ├── admin/
    ├── client/
    └── ...
```

---

## Summary

All decisions confirmed. Ready for implementation!

Key points:
- No trial period → New users must pay to create documents
- Sequential numbering per user/year (legal requirement)
- Tool execution: One at a time (Option B)
- LLM handles onboarding naturally via system prompt
- Default VAT 20%, user can specify different rate
