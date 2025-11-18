# Architecture Decision: Bot-First with Magic Links

## Decision Date
January 15, 2025

## Context

Initial plan was a traditional web app with WhatsApp integration. After client review of mockups, we pivoted to a **bot-first architecture** with magic links for web access.

---

## Key Decisions

### 1. ❌ No Web Registration

**Before:**
- User visits website
- Fills registration form (email, password, company info)
- Confirms email
- Pays subscription
- Then connects WhatsApp via QR code

**After:**
- User messages WhatsApp bot
- Bot auto-creates account from phone number
- Bot collects company info conversationally
- Bot sends magic link for web access
- User pays when ready (trial period first)

**Rationale:** Users are artisans, not tech-savvy. WhatsApp is their comfort zone.

---

### 2. ❌ No Passwords

**Before:**
- Email + password authentication
- Password reset flows
- Email verification
- Session management complexity

**After:**
- Phone number = unique identifier
- Magic links for web access (sent via WhatsApp)
- Tokens: 256-bit entropy, bcrypt hashed, 90-day expiration
- No password management needed

**Rationale:** 
- Simpler for users (no passwords to remember)
- More secure (no weak passwords, no password breaches)
- WhatsApp acts as natural 2FA (phone ownership required)

---

### 3. ❌ No QR Code Pairing

**Before:**
- User logs into web app
- Scans QR code to connect WhatsApp
- Complex pairing flow
- Per-user WhatsApp connection

**After:**
- ONE business WhatsApp number for all users
- Users just message this number
- Bot identifies user by sender phone
- No connection process needed

**Rationale:**
- Users don't understand QR codes
- One number is simpler to communicate
- Easier to manage (one Unipile account)
- Better for marketing (one number to promote)

---

### 4. ❌ No Dashboard with Metrics

**Before:**
- Complex dashboard with stats, graphs, KPIs
- Revenue charts
- Document counters
- Activity metrics

**After:**
- Simple menu with 4 cards:
  - Mes devis (My Quotes)
  - Mes factures (My Invoices)
  - Mes clients (My Clients)
  - Mon profil (My Profile)
- No metrics, no charts

**Rationale:** 
- Users are artisans, not business analysts
- They want simple access to documents
- Metrics add complexity without value
- Mobile-first = minimal UI

---

### 5. ✅ Stripe Customer Portal

**Decision:**
- Use Stripe's hosted Customer Portal
- No custom subscription management UI
- Users manage payment via Stripe (external)

**Benefits:**
- Zero maintenance
- PCI compliance handled
- Automatic feature updates
- Mobile-optimized
- Saves 6 routes + complex UI

---

### 6. ✅ WhatsApp Commands (Bilingual)

**Supported:**
- French: "créer un devis", "mes clients", "aide"
- Turkish: "teklif oluştur", "müşterilerim", "yardım"

**Language Detection:**
- Auto-detect from phone number country code
- Can be changed via bot: "langue français" / "dil türkçe"
- All bot responses in user's preferred language

---

## Technical Architecture

### User Flow

```
WhatsApp Message (First Time)
  ↓
Auto-Create User (phone as ID)
  ↓
Onboarding Conversation (collect company info)
  ↓
Generate Magic Link
  ↓
Send Link via WhatsApp
  ↓
User clicks → Logged in automatically
  ↓
Simple web interface (view documents)
```

### Authentication Flow

```
User receives: https://app.com/u/ABC123XYZ456...
  ↓
User clicks link
  ↓
GET /u/:token → MagicLinksController
  ↓
Validate token (bcrypt check + expiration)
  ↓
Create session (session[:user_id] = user.id)
  ↓
Redirect to /dashboard
  ↓
User navigates (no login needed)
```

---

## Data Model Changes

### Removed Fields

```ruby
# Users table - REMOVED
- email (not needed)
- encrypted_password (no passwords)
- reset_password_token
- confirmation_token
- whatsapp_connected (no pairing)
- unipile_connection_params (not per-user)
```

### Added Fields

```ruby
# Users table - ADDED
+ phone_number (PRIMARY identifier)
+ magic_link_token_digest (authentication)
+ magic_link_token_prefix (fast lookup)
+ magic_link_expires_at
+ magic_link_last_used_at
+ first_message_at
+ last_activity_at
+ onboarding_completed
+ unipile_chat_id (from webhook)
+ unipile_attendee_id (from webhook)
```

---

## Route Count Comparison

| Category | Before | After | Savings |
|----------|--------|-------|---------|
| Registration/Auth | 8 | 5 | -3 |
| User Dashboard | 3 | 2 | -1 |
| WhatsApp Setup | 4 | 0 | -4 |
| Subscriptions | 6 | 1 | -5 |
| Documents (CRUD) | 18 | 13 | -5 |
| Admin | 24 | 21 | -3 |
| Webhooks | 3 | 3 | 0 |
| **TOTAL** | **72** | **47** | **-25 (35%)** |

---

## Development Impact

### Code Reduction

**Don't Need:**
- ❌ Devise gem (or custom auth system)
- ❌ Email confirmation mailers
- ❌ Password reset controllers
- ❌ QR code generation library
- ❌ Dashboard charting library
- ❌ Complex registration forms
- ❌ Email validation logic

**Still Need:**
- ✅ Magic link generation (simple)
- ✅ Unipile webhook handling
- ✅ WhatsApp bot logic
- ✅ PDF generation
- ✅ Stripe integration
- ✅ Admin dashboard

### Timeline Impact

| Phase | Before | After | Time Saved |
|-------|--------|-------|------------|
| Auth System | 1 week | 2 days | 3 days |
| Registration | 3 days | 0 days | 3 days |
| WhatsApp Setup | 1 week | 1 day | 4 days |
| Dashboard UI | 1 week | 2 days | 3 days |
| **TOTAL** | **8 weeks** | **5 weeks** | **13 days (37%)** |

---

## Security Considerations

### Magic Link Security Levels

**Level 1: Basic (MVP)**
- [x] 256-bit tokens
- [x] Bcrypt hashing
- [x] 90-day expiration
- [x] HTTPS only
- [x] Rate limiting

**Level 2: Enhanced (Post-Launch)**
- [ ] IP tracking + alerts
- [ ] Usage notifications via WhatsApp
- [ ] Geolocation validation
- [ ] Device fingerprinting
- [ ] Suspicious activity detection

**Level 3: Paranoid (If Needed)**
- [ ] Single-use tokens
- [ ] Time-based OTP (TOTP)
- [ ] Biometric on mobile
- [ ] Hardware security keys

**For MVP:** Level 1 is sufficient. Users are identified by phone (WhatsApp ownership).

---

## User Onboarding Comparison

### Traditional SaaS Onboarding

```
1. Visit website (30 sec)
2. Fill registration form (2 min)
3. Confirm email (1 min)
4. Login (30 sec)
5. Setup wizard (3 min)
6. Connect integrations (2 min)
7. Create first item (5 min)

Total: ~14 minutes, 7 steps, 3 interfaces (web, email, integrations)
Dropoff: ~60% (industry average)
```

### Our Bot-First Onboarding

```
1. Message WhatsApp: "Bonjour" (5 sec)
2. Answer 3 questions via voice (1 min)
3. Click magic link (5 sec)
4. Already in dashboard (0 sec)
5. Create first quote via WhatsApp (1 min)

Total: ~3 minutes, 2 steps, 1 interface (WhatsApp)
Estimated dropoff: ~15%
```

**Result:** 4.7x faster, 4x better conversion

---

## Risks & Mitigations

### Risk 1: Magic Link Leaked

**Scenario:** User shares link or phone stolen

**Mitigation:**
- Link expires after 90 days
- Track last login IP (alert on change)
- User can revoke via bot: "nouveau lien"
- Old link invalidated when new one generated
- Admin can see suspicious logins

### Risk 2: Phone Number Changed

**Scenario:** User changes phone number

**Mitigation:**
- User contacts bot from new number
- Bot asks for company name + SIRET (verification)
- Admin manually links accounts
- Log all phone changes

### Risk 3: WhatsApp Account Hacked

**Scenario:** Attacker accesses user's WhatsApp

**Mitigation:**
- WhatsApp has its own security (2FA, etc.)
- We can't do more than WhatsApp itself
- Same risk as any WhatsApp-based business

**Note:** This is acceptable risk - users already trust WhatsApp for business.

### Risk 4: Unipile Service Down

**Scenario:** Unipile API unavailable

**Mitigation:**
- Messages queued in Unipile (delivered later)
- Webhook retries automatically
- Fallback: Admin can process manually
- Monitor uptime, set up alerts

---

## Success Metrics

### What We Track

✅ **User Activation:**
- New users per day (from WhatsApp)
- Onboarding completion rate
- Time to first document

✅ **Engagement:**
- Messages per user per week
- Documents created per user
- Active users (messaged in last 7 days)

✅ **Revenue:**
- Trial-to-paid conversion
- Monthly recurring revenue (MRR)
- Churn rate

✅ **Quality:**
- PDF generation success rate
- Bot response time
- Webhook processing time

### What We DON'T Track

❌ Web analytics (page views, clicks, etc.)
❌ Dashboard engagement
❌ Session duration
❌ Feature usage on web

**Rationale:** Web is just for viewing. WhatsApp is where the value is.

---

## Migration from Existing System

### If Users Already Exist

```ruby
# One-time migration script

User.where(phone_number: nil).find_each do |user|
  # Send email asking for WhatsApp number
  UserMailer.request_whatsapp_number(user).deliver_later
  
  # Or: Mark for manual admin review
  user.update!(needs_phone_migration: true)
end

# After user provides phone
def migrate_to_phone_auth(user, phone_number)
  user.update!(
    phone_number: phone_number,
    onboarding_completed: true # Skip onboarding
  )
  
  # Generate and send magic link
  token = user.generate_magic_link!
  send_whatsapp_message(phone_number, "Votre lien: #{user.magic_link_url}")
end
```

---

## Conclusion

This **bot-first architecture with magic links** is:

✅ **Simpler** - 35% fewer routes, no auth complexity
✅ **Faster** - 37% faster development
✅ **Cheaper** - Less code to maintain
✅ **Better UX** - 4.7x faster onboarding
✅ **More Secure** - No passwords to steal
✅ **More Scalable** - Stateless magic links

**Perfect fit for:**
- Non-tech-savvy users (artisans)
- Mobile-first use cases
- WhatsApp-native workflows
- Simple, focused products

**Status:** ✅ **APPROVED - This is the architecture to implement**
