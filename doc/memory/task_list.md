# BTP Assistant - Implementation Task List

## Project Overview

Application for small BTP entrepreneurs (artisans, masons) to create quotes and invoices via voice commands on WhatsApp, with bilingual French-Turkish support. **Bot-first architecture** with LLM-powered conversation using function calling.

### Key Architecture Decisions

See `doc/memory/architecture_decisions.md` for full details.

| Decision | Choice |
|----------|--------|
| Audio handling | Whisper transcription → then text to GPT-4 |
| Context window | Last 10-15 messages OR last 2 hours |
| Tool execution | **Option B**: One tool at a time, send result back to LLM |
| PDF sending | Auto-send after creation |
| Error handling | Return structured error to GPT-4 |
| Onboarding | System prompt + tools (no hardcoded flow) |
| Rate limiting | Soft limit 50 msg/hour/user |
| Subscription | **NO TRIAL** - Must pay to create documents |
| Document numbering | Sequential, no gaps, scoped per user/year |
| VAT | Default 20%, user can specify |
| Webhook duplicates | Check `unipile_message_id` uniqueness |

---

## Authentication Architecture

| Role | Model | Authentication |
|------|-------|----------------|
| **Admin** | `Admin` | Devise (email/password) |
| **User (Artisan)** | `User` | Phone = Identity, Signed URLs for web (30 min) |

---

## Phase 1: Core Infrastructure ✅ COMPLETE

### 1.1 Database Schema & Models ✅

All migrations created and run:
- [x] Admin model (renamed from User) ✅
- [x] AppSetting model (singleton with encryption) ✅
- [x] User model (artisan, phone-based identity) ✅
- [x] Client model ✅
- [x] Quote model (sequential numbering per user/year) ✅
- [x] QuoteItem model ✅
- [x] Invoice model (sequential numbering per user/year) ✅
- [x] InvoiceItem model ✅
- [x] WhatsappMessage model ✅
- [x] LlmConversation model ✅
- [x] Subscription model ✅
- [x] SubscriptionInvoice model ✅
- [x] SystemLog model ✅
- [x] LlmPrompt model ✅

### 1.2 Model Implementation ✅

- [x] Admin with Devise authentication ✅
- [x] AppSetting with singleton pattern and encryption ✅
- [x] User with phone validation (E.164), status helpers ✅
- [x] Client with search, financial helpers ✅
- [x] Quote with sequential numbering, status workflow ✅
- [x] Invoice with sequential numbering, status workflow ✅
- [x] WhatsappMessage with duplicate detection ✅
- [x] LlmConversation with analytics ✅
- [x] Subscription with Stripe sync ✅
- [x] SystemLog with factory methods ✅
- [x] LlmPrompt with seed defaults ✅

---

## Phase 2: Signed URL System ✅ COMPLETE

- [x] SignedUrlService with HMAC signature ✅
- [x] UserSessionsController ✅
- [x] Session management with 2-hour freshness ✅
- [x] Bilingual views (FR/TR) ✅
- [x] Tests ✅

---

## Phase 3: Unipile Integration ✅ COMPLETE

- [x] UnipileClient service ✅
- [x] Webhook handler ✅
- [x] ProcessWhatsappMessageJob ✅
- [x] Tests ✅

---

## Phase 4: LLM with Tools ✅ COMPLETE

- [x] OpenaiClient (GPT-4 + Whisper) ✅
- [x] 13 Tool definitions ✅
- [x] Tool executors ✅
- [x] ConversationEngine (Option B loop) ✅
- [x] AudioTranscriber ✅
- [x] Tests ✅

---

## Phase 5: PDF Generation ✅ COMPLETE

- [x] PdfGenerators::BasePdf ✅
- [x] PdfGenerators::QuotePdf ✅
- [x] PdfGenerators::InvoicePdf ✅
- [x] Tool updates for PDF sending ✅
- [x] Tests ✅

---

## Phase 6: Stripe Integration ✅ COMPLETE

- [x] StripeService ✅
- [x] Webhook handler ✅
- [x] SendPaymentLink tool ✅
- [x] Payment result pages ✅
- [x] Tests ✅

---

## Phase 7: User Web Interface ✅ COMPLETE

### 7.1 Dashboard ✅
- [x] `GET /dashboard` - Navigation cards
- [x] Quote, invoice, client counts
- [x] Links to all sections

### 7.2 Quotes Views ✅
- [x] `GET /quotes` - List with search, filters, pagination
- [x] `GET /quotes/:id` - Quote details with items
- [x] `GET /quotes/:id/pdf` - PDF download
- [x] `POST /quotes/:id/send_whatsapp` - Resend via WhatsApp

### 7.3 Invoices Views ✅
- [x] `GET /invoices` - List with search, filters, pagination
- [x] `GET /invoices/:id` - Invoice details with items
- [x] `GET /invoices/:id/pdf` - PDF download
- [x] `POST /invoices/:id/send_whatsapp` - Resend via WhatsApp

### 7.4 Clients Views ✅
- [x] `GET /clients` - List with search
- [x] `GET /clients/:id` - Client details with stats

### 7.5 Profile Management ✅
- [x] `GET /profile` - View profile & subscription
- [x] `PATCH /profile` - Update profile
- [x] `POST /profile/billing_portal` - Stripe portal redirect

### 7.6 Supporting Components ✅
- [x] Client layout with header, burger menu
- [x] Pagination helper in BaseController
- [x] Status badges (quote, invoice)
- [x] French translations (client.fr.yml)
- [x] Turkish translations (client.tr.yml)

### 7.7 Tests ✅
- [x] Dashboard controller tests (6 tests)
- [x] Quotes controller tests (14 tests)
- [x] Invoices controller tests (13 tests)
- [x] Clients controller tests (10 tests)
- [x] Profile controller tests (13 tests)

---

## Phase 8: Admin Interface ⏳ NEXT

### 8.1 Admin Dashboard
- [ ] Metrics overview (users, quotes, invoices, revenue)
- [ ] Recent activity feed
- [ ] System health status
- [ ] Quick actions

### 8.2 User Management
- [ ] `GET /admin/users` - List all users with filters
- [ ] `GET /admin/users/:id` - User details
- [ ] `POST /admin/users/:id/suspend` - Suspend user
- [ ] `POST /admin/users/:id/activate` - Activate user
- [ ] `GET /admin/users/:id/logs` - User activity logs

### 8.3 Subscription Management
- [ ] `GET /admin/subscriptions` - All subscriptions
- [ ] `GET /admin/subscriptions/overdue` - Overdue payments
- [ ] Stripe portal link per user

### 8.4 Document Views
- [ ] `GET /admin/quotes` - All quotes (global)
- [ ] `GET /admin/invoices` - All invoices (global)
- [ ] `GET /admin/clients` - All clients (global)

### 8.5 System Monitoring
- [ ] `GET /admin/system_logs` - System logs viewer
- [ ] `GET /admin/whatsapp_messages` - WhatsApp logs
- [ ] `GET /admin/llm_conversations` - LLM logs

### 8.6 Settings Management
- [ ] `GET /admin/settings` - App settings
- [ ] `GET /admin/settings/unipile` - Unipile config
- [ ] `GET /admin/settings/stripe` - Stripe config
- [ ] `GET /admin/settings/openai` - OpenAI config
- [ ] `POST /admin/settings/test_connection` - Test APIs

### 8.7 Prompt Management
- [ ] `GET /admin/prompts` - List prompts
- [ ] `GET /admin/prompts/:id/edit` - Edit prompt
- [ ] `POST /admin/prompts/:id/test` - Test prompt

### 8.8 Tests
- [ ] Dashboard controller tests
- [ ] Users controller tests
- [ ] Subscriptions controller tests
- [ ] Settings controller tests
- [ ] System logs controller tests

---

## Phase 9-10: Testing & Deployment

### Phase 9: End-to-end Testing
- [ ] Full user journey tests
- [ ] WhatsApp integration tests (mocked)
- [ ] Stripe webhook tests
- [ ] Error handling tests

### Phase 10: Deployment
- [ ] Production configuration
- [ ] Database setup
- [ ] Environment variables
- [ ] Webhook URL configuration
- [ ] SSL certificates
- [ ] Monitoring setup

---

## Test Summary

| Category | Tests | Status |
|----------|-------|--------|
| Admin model | 4 | ✅ |
| User model | 18 | ✅ |
| Quote model | 13 | ✅ |
| SignedUrlService | 17 | ✅ |
| UserSessionsController | 7 | ✅ |
| HomeController | 1 | ✅ |
| MockupsController | 1 | ✅ |
| UnipileClient | 21 | ✅ |
| Webhooks::Unipile::MessagesController | 16 | ✅ |
| ProcessWhatsappMessageJob | 11 | ✅ |
| OpenaiClient | 18 | ✅ |
| LlmTools::Executor | 11 | ✅ |
| LlmTools::SearchClients | 10 | ✅ |
| LlmTools::CreateClient | 12 | ✅ |
| LlmTools::CreateQuote | 16 | ✅ |
| LlmTools::CreateInvoice | 15 | ✅ |
| ConversationEngine | 15 | ✅ |
| AudioTranscriber | 14 | ✅ |
| PdfGenerators::QuotePdf | 16 | ✅ |
| PdfGenerators::InvoicePdf | 16 | ✅ |
| StripeService | 17 | ✅ |
| Webhooks::StripeController | 14 | ✅ |
| LlmTools::SendPaymentLink | 11 | ✅ |
| Client::DashboardController | 6 | ✅ |
| Client::QuotesController | 14 | ✅ |
| Client::InvoicesController | 13 | ✅ |
| Client::ClientsController | 10 | ✅ |
| Client::ProfileController | 13 | ✅ |
| **Total** | **~352** | **✅** |

---

## Dependencies (Installed)

```ruby
gem 'devise'        # ✅ Installed
gem 'phonelib'      # ✅ Installed
gem 'prawn'         # ✅ Installed
gem 'prawn-table'   # ✅ Installed
gem 'ruby-openai'   # ✅ Installed
gem 'stripe'        # ✅ Installed
gem 'rack-attack'   # ✅ Installed
gem 'faraday'       # ✅ Installed
gem 'faraday-multipart' # ✅ Installed
gem 'webmock'       # ✅ Installed (test)
gem 'mocha'         # ✅ Installed (test)
```

---

## Recent Changes (2025-01-15)

### Phase 7 Complete ✅
- Created Client::DashboardController with real data
- Created Client::QuotesController with filters, PDF, WhatsApp
- Created Client::InvoicesController with filters, PDF, WhatsApp
- Created Client::ClientsController with search, stats
- Created Client::ProfileController with Stripe billing portal
- Created all views matching mockup designs
- Added pagination helper to BaseController
- Created bilingual translations (FR/TR)
- Created 56 controller tests

---

*Status: Phase 7 Complete - Ready for Phase 8 (Admin Interface)*
