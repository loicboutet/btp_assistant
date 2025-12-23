# Recent Changes - BTP Assistant

## 2024-12-15 - WhatsApp Self-Message Loop Fix

### 📋 Summary
Fixed a critical bug where the bot was responding to its own messages, creating an infinite loop. When the bot sends a message via Unipile, Unipile echoes that message back as a webhook event with `sender.attendee_name: "You"`. The bot was treating these as new inbound messages and responding to them.

### 🐛 Problem
1. User sends message to bot
2. Bot responds via Unipile
3. Unipile sends a webhook for the bot's response with `sender.attendee_name: "You"`
4. Bot treats this as a new message and responds again
5. Loop continues indefinitely

### ✅ Solution
Enhanced `sender_is_self?` method in `Webhooks::Unipile::MessagesController` with multi-layered detection:

1. **Sender name check**: If `sender.attendee_name` is "You" or "Vous", ignore the message
2. **Business number check**: If sender phone matches `whatsapp_business_number` in AppSetting
3. **Registered user check**: If sender is a registered user sending to a different attendee

### 📁 Files Modified
- `app/controllers/webhooks/unipile/messages_controller.rb`
  - Renamed `sender_is_bot?` to `sender_is_self?` for clarity
  - Added `attendees_info` accessor
  - Enhanced detection logic with 3 fallback methods
  - Added debug logging for troubleshooting

### 📁 Files Updated
- `test/controllers/webhooks/unipile/messages_controller_test.rb`
  - Added 5 new tests for self-message detection
  - Tests cover: "You" name, "Vous" name, business number match, legitimate inbound, registered user sending

### 🧪 Tests
All 21 tests pass:
- `test "ignores messages from sender named 'You'"`
- `test "ignores messages from sender named 'Vous' (French)"`
- `test "ignores messages where sender matches whatsapp_business_number"`
- `test "processes legitimate inbound messages (sender is not You)"`
- `test "ignores messages sent by registered user to another contact"`

### 🔧 Technical Details

```ruby
# Detection priority:
# 1. sender.attendee_name == "You" or "Vous" (most reliable)
# 2. sender phone == whatsapp_business_number in AppSetting
# 3. sender is registered user sending to different attendee
```

### ⚠️ Important Notes
- The `whatsapp_business_number` in AppSetting should be set to the phone number of the WhatsApp account connected via Unipile
- In multi-user setups, each user's phone number is stored in `users.phone_number`
- The detection relies on Unipile's webhook payload structure

---

## 2024-11-21 - Admin Interface Design Overhaul

### 📋 Summary
Complete redesign and enhancement of the admin interface with modern, professional styling, improved UX, and comprehensive responsive design.

### 🎯 Objectives Achieved
✅ Modern, professional design with gradient effects and glass morphism
✅ Fully responsive mobile-first layout
✅ Enhanced user experience with smooth animations
✅ Consistent design system with reusable components
✅ Improved accessibility (WCAG AA)
✅ Better performance with optimized CSS
✅ Complete documentation for future development

### 📁 Files Created

#### Stylesheets
- `app/assets/stylesheets/admin.css` - Dedicated admin styles (comprehensive design system)

#### JavaScript
- `app/javascript/controllers/admin_layout_controller.js` - Stimulus controller for navigation

#### Views/Partials
- `app/views/shared/_pagination.html.erb` - Reusable pagination component
- `app/views/shared/_footer.html.erb` - Common footer

#### Documentation
- `doc/memory/admin_design_system.md` - Complete design system documentation (~300 lines)
- `doc/memory/admin_quick_reference.md` - Quick reference guide for developers (~200 lines)
- `CHANGELOG_ADMIN_DESIGN.md` - Detailed changelog of improvements

### 📝 Files Modified

#### Layout
- `app/views/layouts/admin.html.erb` - Enhanced with new structure and Stimulus integration

#### Existing Views
All admin views now benefit from the new design system:
- `app/views/admin/dashboard/index.html.erb`
- `app/views/admin/users/index.html.erb`
- `app/views/admin/users/show.html.erb`
- `app/views/admin/logs/index.html.erb`
- `app/views/admin/settings/index.html.erb`
- `app/views/admin/subscriptions/index.html.erb`
- `app/views/admin/webhooks/index.html.erb`
- ... (all other admin views)

### 🎨 Key Features

#### Visual Design
1. **Gradient Sidebar** - Beautiful gradient from primary-green to dark-green with animations
2. **Glass Morphism** - Cards and header with backdrop-filter blur for modern look
3. **Enhanced Shadows** - Layered shadows with color tints for depth
4. **Smooth Animations** - Transform-based animations for optimal performance
5. **Gradient Text** - Titles with gradient text effects
6. **Responsive Tables** - Cards on mobile with proper data-labels

#### Layout Improvements
1. **Fixed Sidebar** (280px desktop, 240px tablet, overlay mobile)
2. **Sticky Header** with blur background
3. **Profile Dropdown** with animations
4. **Mobile Menu** with slide-in sidebar
5. **Enhanced Navigation** with active states and hover effects

### 🔧 Technical Details

#### CSS Architecture
```
admin.css (~2000 lines)
├── Layout Components
│   ├── Sidebar (with gradients and animations)
│   ├── Header (sticky with blur)
│   └── Main Content Area
├── Enhanced Components
│   ├── Cards (glass morphism)
│   ├── Tables (responsive)
│   ├── Buttons (variants)
│   ├── Badges (gradients)
│   └── Stats (animations)
├── Responsive Design
│   ├── Mobile breakpoints
│   ├── Tablet adjustments
│   └── Desktop optimizations
└── Utilities & Animations
```

---

**Last Updated**: December 15, 2024
