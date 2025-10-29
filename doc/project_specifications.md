# Project Specifications

## 2.1 General Project Description

Application enabling small construction entrepreneurs (artisans, masons) to create quotes and invoices via voice commands on WhatsApp, with bilingual French-Turkish support.

The objective is to facilitate administrative management for non-French speaking users who are not comfortable with computers.

## 2.2 Features to Develop

### WEB REGISTRATION & PAYMENT INTERFACE

#### User Registration
- Public registration page with form: first name, last name, email, WhatsApp phone number, company name, SIRET number, address, VAT number (optional), preferred language (French/Turkish)
- Stripe payment system integration for monthly recurring subscription
- Automatic generation of subscription invoice with information provided by the user
- Welcome email sent with WhatsApp connection instructions after payment

#### Client Dashboard
- Responsive web interface for viewing quote and invoice history
- Document organization by type (quote/invoice), date, client
- PDF document download
- Subscription status consultation

### ADMIN MANAGEMENT (5000.dev)

#### Account Administration
- Manual creation and configuration of user accounts after payment
- System logs and usage metrics visualization
- Account suspension/reactivation
- General application settings management
- Stripe subscription and payment tracking

### WHATSAPP INTEGRATION VIA UNIPILE

#### Connection and Messaging
- Connection of the artisan's personal WhatsApp account via Unipile
- Link 1 account = 1 WhatsApp number = 1 SIRET
- Webhook for real-time message reception
- Reception of voice and text messages

### INTELLIGENT MESSAGE PROCESSING

#### Voice Recognition and Conversation
- Audio file reception via Unipile
- Automatic transcription via OpenAI Whisper API (French and Turkish support)
- Automatic spoken language detection
- Text processing via OpenAI GPT-4 with intelligent conversational workflow
- Automatic text responses in the language detected by the user

### CLIENT MANAGEMENT

#### Client CRUD via WhatsApp
- Client creation via guided WhatsApp conversation (voice or text)
- Stored information: name, address, SIRET (if professional), contacts
- Search for existing client when creating documents
- Consultable client list

### QUOTE CREATION

#### Conversational Workflow for Quotes
- Creation triggered via voice or text command on WhatsApp
- Detection or creation of recipient client
- Guided entry of service lines: description, quantity, unit price
- Automatic calculation of VAT and totals
- Text summary sent on WhatsApp before validation
- Professional PDF generation with customized template
- PDF sent directly on WhatsApp
- Document storage in history

### INVOICE CREATION

#### Conversational Workflow for Invoices
- Creation triggered via voice or text command on WhatsApp
- Ability to link an invoice to an existing quote
- Ability to create an independent invoice without quote
- Guided entry of service lines: description, quantity, unit price
- Automatic calculation of VAT and totals
- Text summary sent on WhatsApp before validation
- Professional PDF generation with customized template
- PDF sent directly on WhatsApp
- Document storage in history

### STORAGE AND ARCHIVING

#### Document Management
- Secure storage of generated PDFs
- Automatic organization by user, document type, date
- Complete history retention
- Quick access via web interface

### SUBSCRIPTION MANAGEMENT

#### Recurring Payment System
- Automatic monthly payment via Stripe
- Automatic generation of monthly subscription invoices
- Reminder emails sent before payment
- Automatic account suspension in case of non-payment
- Possible reactivation after settlement

## 2.3 Explicitly Excluded Elements

The following elements are explicitly excluded from the scope of this component:

- Native mobile application (iOS/Android)
- Automatic sending of documents to the artisan's end clients
- Management of supporting documents and construction site photos
- Automatic reminder system for unpaid invoices
- Mandatory electronic invoicing (deadline September 2026)
- Advanced accounting export to third-party software
- Multi-user management per company
- Arabic language support (only French and Turkish in this component)
- Voice responses from the assistant (only text responses)
- Integration with other messaging platforms
- Electronic document signature system

This feature list constitutes the contractual scope of the developments to be performed.
