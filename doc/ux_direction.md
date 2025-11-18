# UX Direction & Design Principles

## Client Feedback - January 2025

### Core Philosophy: WhatsApp-First

**Key Insight:** The app must be **WhatsApp-first**, not just mobile-first. Users should barely need the web interface.

### Major Changes from Initial Mockups

#### 1. ❌ NO QR Code Connection Flow

**Initial Plan (Rejected):**
- User logs into web app
- Clicks "Connect WhatsApp"
- Scans QR code
- Complex connection flow

**New Direction (Approved):**
- Direct link from web app to WhatsApp conversation
- One click → Opens WhatsApp with pre-filled message to our agent
- Zero friction, zero technical complexity
- No QR scanning, no pairing process

**Implementation:**
```
Click "Open WhatsApp" → Opens WhatsApp deep link
whatsapp://send?phone=AGENT_NUMBER&text=Bonjour
```

#### 2. 🎯 Drastically Simplified UI

**Remove:**
- ❌ Dashboard with metrics/stats
- ❌ Complex analytics
- ❌ Graphs and charts
- ❌ Fancy data visualizations
- ❌ "Business intelligence" features

**Reasoning:** These features are **not relevant** for artisan users. They add complexity without value.

**Keep:**
- ✅ Simple lists (quotes, invoices, clients)
- ✅ Basic search functionality
- ✅ PDF download
- ✅ Minimal profile page

### Updated Screen Breakdown

Based on provided mockups:

#### Screen 1: Main Menu (Home)
```
┌─────────────────────┐
│ 🟢 WhatsApp  ☰     │  ← WhatsApp icon + hamburger menu
├─────────────────────┤
│                     │
│  ┌───────────────┐  │
│  │   Mes devis   │  │  ← Simple card/button
│  └───────────────┘  │
│                     │
│  ┌───────────────┐  │
│  │ Mes factures  │  │
│  └───────────────┘  │
│                     │
│  ┌───────────────┐  │
│  │ Mes clients   │  │
│  └───────────────┘  │
│                     │
│  ┌───────────────┐  │
│  │  Mon profil   │  │
│  └───────────────┘  │
│                     │
└─────────────────────┘
```

**Design Notes:**
- **Large, tappable cards** (not small buttons)
- **Lots of whitespace**
- **No dashboard, no stats** - just direct access to resources
- **WhatsApp icon prominent** in top-left (click to open chat)

#### Screen 2: List View with Search (e.g., Quotes)
```
┌─────────────────────┐
│ 🟢 WhatsApp  ☰     │
├─────────────────────┤
│ ┌─────────────────┐ │
│ │ 🔍 Search...    │ │  ← Search bar
│ └─────────────────┘ │
│                     │
│ ┌─────────────────┐ │
│ │ 📄 clients      │ │  ← Filter: clients
│ └─────────────────┘ │
│                     │
│ ┌─────────────────┐ │
│ │ 📅 mois         │ │  ← Filter: month
│ └─────────────────┘ │
│                     │
│ ┌─────────────────┐ │
│ │                 │ │
│ │  (List items)   │ │  ← Results area
│ │                 │ │
│ └─────────────────┘ │
│                     │
└─────────────────────┘
```

**Design Notes:**
- **Simple search bar** at top
- **2 filter pills** (clients, month) - not complex filters
- **Large result area** below
- **No pagination** - infinite scroll or "Load more"

#### Screen 3: Hamburger Menu (Side Navigation)
```
┌─────────────────────┐
│ 🟢 WhatsApp  ☰     │
├─────────────────────┤
│ MES DEVIS          │  ← Menu items
│ MES FACTURES       │
│ MES CLIENTS        │
│ CONVERSATIONS      │
│ MON PROFIL         │
│ ABONNEMENT         │
│ TUTO YOUTUBE       │  ← Link to tutorial
├─────────────────────┤
│                     │
│  ┌───────────────┐  │
│  │   Mes devis   │  │  ← Main content still visible
│  └───────────────┘  │
│                     │
│  ┌───────────────┐  │
│  │ Mes factures  │  │
│  └───────────────┘  │
│                     │
│  ┌───────────────┐  │
│  │ Mon clients   │  │
│  └───────────────┘  │
│                     │
└─────────────────────┘
```

**Design Notes:**
- **Overlay menu** (dark background, menu slides from left)
- **Simple text links** - no icons needed in menu
- **YouTube tutorial link** - helps onboarding
- **Keep menu short** - 7 items max

---

## Revised User Journey

### For New User (Registration)

```
1. Landing page (web)
   → Click "S'inscrire"
   
2. Registration form (web)
   → Fill: name, email, phone, company, SIRET
   → Submit
   
3. Stripe Checkout (external)
   → Pay subscription
   
4. Success page (web)
   → "Bienvenue ! Cliquez pour ouvrir WhatsApp"
   → Button: "Ouvrir WhatsApp" 
   
5. WhatsApp opens (mobile app)
   → Pre-filled message: "Bonjour, je viens de m'inscrire"
   → User sends message
   
6. Bot responds (WhatsApp)
   → "Bienvenue ! Tapez 'aide' pour commencer"
```

**Key:** No web dashboard needed. User goes **directly to WhatsApp**.

### For Existing User (Daily Use)

**99% WhatsApp:**
```
User opens WhatsApp
  → "créer un devis"
  → Bot guides through quote creation
  → PDF generated and sent on WhatsApp
  
DONE. Never opens web app.
```

**1% Web (occasional):**
```
User needs to:
  - View old quotes → Opens web app → /quotes → Downloads PDF
  - Check client info → Opens web app → /clients → Views details
  - Manage subscription → Opens web app → Stripe Portal
```

---

## Updated Route Strategy

### Extremely Simplified Web Routes

**Keep Only Essential Routes:**

#### Public (3 routes)
- `GET /` - Landing
- `GET /sign_up` - Registration form
- `POST /sign_up` - Process registration + Stripe

#### Authenticated User (12 routes - minimal!)
- `GET /login` - Login (rarely used after initial setup)
- `POST /login`
- `DELETE /logout`

- `GET /quotes` - Simple list
- `GET /quotes/:id` - View + download PDF

- `GET /invoices` - Simple list  
- `GET /invoices/:id` - View + download PDF

- `GET /clients` - Simple list
- `GET /clients/:id` - View details

- `GET /conversations` - WhatsApp history (read-only)

- `GET /profile` - Basic info + WhatsApp link
- `POST /subscription/portal` - Stripe portal redirect

**Total User Routes: ~15** (down from 72!)

#### Admin (keep as is)
- Admin needs full visibility
- Keep `/admin/*` routes

---

## WhatsApp Deep Link Strategy

### Direct WhatsApp Link (No QR Code)

**From Web App:**
```html
<!-- Mobile -->
<a href="whatsapp://send?phone=33XXXXXXXXX&text=Bonjour">
  Ouvrir WhatsApp
</a>

<!-- Desktop (opens WhatsApp Web) -->
<a href="https://wa.me/33XXXXXXXXX?text=Bonjour">
  Ouvrir WhatsApp Web
</a>
```

**From Success Page After Registration:**
```html
<div class="success-card">
  <h1>✅ Inscription réussie !</h1>
  <p>Commencez maintenant en ouvrant WhatsApp</p>
  
  <a href="whatsapp://send?phone=33XXXXXXXXX&text=Bonjour,%20je%20viens%20de%20m'inscrire" 
     class="big-green-button">
    🟢 Ouvrir WhatsApp
  </a>
  
  <p class="small-text">
    Vous pouvez aussi nous écrire sur WhatsApp au 06 XX XX XX XX
  </p>
</div>
```

**User Flow:**
1. Click button
2. WhatsApp opens automatically
3. Message pre-filled
4. User just hits "Send"
5. Conversation starts immediately

**Benefits:**
- ✅ Zero friction
- ✅ Works on mobile AND desktop
- ✅ No technical complexity
- ✅ User understands immediately

---

## Revised Feature Priorities

### Phase 1 (MVP) - Absolutely Essential

1. ✅ Registration + Stripe payment
2. ✅ WhatsApp deep links (no QR code)
3. ✅ WhatsApp bot (Unipile + OpenAI)
4. ✅ Quote creation via WhatsApp
5. ✅ Invoice creation via WhatsApp
6. ✅ PDF generation and sending
7. ✅ Simple web lists (quotes, invoices, clients)
8. ✅ PDF download from web

**NO Dashboard, NO Analytics, NO Complex UI**

### Phase 2 (After Launch)

- Client management via WhatsApp
- Conversation history on web
- Better search/filters
- Email notifications for payment issues

### Phase 3 (Future)

- Accounting export
- Multi-language improvements
- Advanced reporting (if users ask for it)

---

## Design System Updates

### Simplified Visual Style

**Colors:**
- Primary: WhatsApp Green (#25D366)
- Background: Light gray (#F5F5F5)
- Cards: White (#FFFFFF)
- Text: Dark gray (#333333)

**Typography:**
- Headings: Bold, large (24px+)
- Body: Regular, readable (16px)
- Keep simple, no fancy fonts

**Components:**

**1. Big Card Button (Main Menu)**
```
┌─────────────────────────┐
│                         │
│      Mes devis          │  ← Large, tappable
│                         │
└─────────────────────────┘
```
- Height: 80-100px
- Border: 1px solid #E0E0E0
- Border-radius: 12px
- Tap area: Full card

**2. Search Bar**
```
┌─────────────────────────┐
│ 🔍 Rechercher...        │  ← Rounded pill
└─────────────────────────┘
```
- Height: 48px
- Border-radius: 24px (full pill)
- Large tap target

**3. Filter Pills**
```
┌──────────────┐  ┌──────────────┐
│ 📄 clients   │  │ 📅 mois      │  ← Small pills
└──────────────┘  └──────────────┘
```
- Height: 40px
- Border-radius: 20px
- Light background

**4. WhatsApp Button (Hero)**
```
┌─────────────────────────┐
│  🟢 Ouvrir WhatsApp     │  ← Big, green, obvious
└─────────────────────────┘
```
- Background: WhatsApp green
- Height: 56px
- White text
- Drop shadow for emphasis

**5. List Items**
```
┌─────────────────────────┐
│ Devis #2025-001         │  ← Simple card
│ Client: Dubois          │
│ 5,100.00 €             │
│ ───────────────────────  │
│ 📄 PDF   📤 WhatsApp    │  ← Action buttons
└─────────────────────────┘
```
- White background
- Border: subtle
- Padding: generous (16px)
- Actions: icons only

---

## Mobile-First Breakpoints

**Mobile (default):**
- 320px - 768px
- Single column
- Large touch targets (48px min)
- Bottom navigation if needed

**Tablet:**
- 768px - 1024px
- Still single column (keep simple)
- Slightly larger cards

**Desktop:**
- 1024px+
- Max-width: 600px (center content)
- Keep mobile layout (don't overcomplicate)

**Rationale:** Users are on mobile. Desktop is just for occasional access. Keep same layout.

---

## Content Strategy

### Microcopy (French)

**Buttons:**
- "Ouvrir WhatsApp" (not "Connecter WhatsApp")
- "Voir le PDF" (not "Télécharger")
- "Mes devis" (not "Liste des devis")

**Instructions:**
- Short sentences
- Active voice
- No jargon

**Example Success Page:**
```
✅ Bienvenue !

Vous êtes inscrit. Pour créer votre premier devis, 
ouvrez WhatsApp et envoyez "créer un devis".

[🟢 Ouvrir WhatsApp]

Besoin d'aide ? Regardez notre tutoriel vidéo.
```

### Help/Tutorial

**YouTube Tutorial Link:**
- Short video (2-3 min)
- Shows: How to create a quote via WhatsApp
- Accessible from hamburger menu
- Optional, not forced

---

## Technical Implications

### What We DON'T Need Anymore

1. ❌ Unipile QR Code API integration
2. ❌ QR code generation libraries
3. ❌ Complex account pairing flow
4. ❌ Polling for connection status
5. ❌ Dashboard metrics calculation
6. ❌ Charts/graphs libraries
7. ❌ Complex state management for dashboard

### What We DO Need

1. ✅ WhatsApp deep links (simple HTML)
2. ✅ Unipile webhook for messages (already planned)
3. ✅ Simple CRUD for quotes/invoices/clients
4. ✅ PDF generation (already planned)
5. ✅ Stripe portal redirect (already planned)

### Simplified Database Needs

**Remove:**
- `whatsapp_connected` boolean (not needed - no QR pairing)
- Dashboard metrics tables

**Keep:**
- All core models (User, Client, Quote, Invoice, etc.)
- WhatsappChat and WhatsappMessage (for history)

---

## Updated Data Model Changes

### User Model Simplification

**Remove these fields:**
```ruby
# NOT NEEDED
whatsapp_connected: boolean
unipile_connection_params: json
```

**Keep:**
```ruby
# STILL NEEDED
whatsapp_phone: string  # For deep link
unipile_account_id: string  # Backend only
```

**Reasoning:** 
- No QR connection = no need to track "connected" status
- User provides phone during registration
- We use that phone for deep links
- Backend still uses Unipile for receiving messages

### WhatsApp Integration Architecture

**Simplified Flow:**

```
Registration:
  User enters phone: +33 6 12 34 56 78
  ↓
  We store in User.whatsapp_phone
  ↓
  Success page shows button with deep link to that number
  ↓
  User clicks → WhatsApp opens with their number

Backend (Invisible to User):
  Admin manually connects WhatsApp account via Unipile (one time)
  ↓
  All users messages go to same business WhatsApp number
  ↓
  Bot identifies user by phone number in message
  ↓
  Bot responds accordingly
```

**Key Insight:** Users never "connect" WhatsApp. They just message the business number. Backend handles everything.

---

## Implementation Checklist

### Phase 1: MVP (Simplified)

**Week 1-2: Core Backend**
- [ ] User registration + Stripe
- [ ] User model (no QR connection fields)
- [ ] Unipile webhook setup
- [ ] OpenAI integration for bot

**Week 3: WhatsApp Bot**
- [ ] Quote creation workflow
- [ ] Invoice creation workflow
- [ ] PDF generation
- [ ] Send PDF via Unipile

**Week 4: Simple Web Interface**
- [ ] Landing page
- [ ] Registration page + success page with WhatsApp button
- [ ] Login page
- [ ] Main menu (4 big cards)
- [ ] Quotes list (simple)
- [ ] Invoices list (simple)
- [ ] Clients list (simple)
- [ ] Profile page
- [ ] Subscription → Stripe portal redirect

**Week 5: Polish & Test**
- [ ] Mobile-first CSS
- [ ] WhatsApp deep links testing (iOS + Android)
- [ ] PDF download testing
- [ ] End-to-end user journey testing

**Total: 5 weeks to MVP** (vs 8-10 weeks with complex dashboard)

---

## Success Metrics (Simplified)

### Don't Track:
- ❌ Dashboard engagement
- ❌ Time spent on web app
- ❌ Feature usage analytics

### Do Track:
- ✅ Successful registrations
- ✅ Active subscriptions
- ✅ Quotes created (via WhatsApp)
- ✅ Invoices created (via WhatsApp)
- ✅ Subscription renewals

**Reasoning:** If users are creating quotes/invoices and paying subscriptions, the app is working. Web analytics don't matter.

---

## Questions to Clarify with Client

1. **WhatsApp Number:**
   - Should we use ONE business WhatsApp number for all users?
   - Or does each user connect their own WhatsApp? (seems like option 1)

2. **Onboarding:**
   - After registration, should we auto-send a WhatsApp message?
   - Or user must initiate first message?

3. **Tutorial:**
   - Do you have a YouTube tutorial already?
   - Or should we create one?

4. **Search/Filters:**
   - Which filters are essential? (client, month - as shown in mockup?)
   - Free text search or just filters?

5. **Profile Page:**
   - What info should be editable?
   - Just name/email or also company details?

---

## Conclusion

**Old Approach:**
- Complex dashboard
- QR code pairing
- Lots of web features
- 72 routes
- 8-10 weeks development

**New Approach (WhatsApp-First):**
- Ultra-simple web app
- Direct WhatsApp links
- Minimal features on web
- ~15 user routes
- 5 weeks development

**Result:**
- ✅ Faster to market
- ✅ Simpler codebase
- ✅ Less maintenance
- ✅ Better UX for target users (artisans)
- ✅ Lower development cost

**This is the right approach for an artisan-focused, WhatsApp-first application.**
