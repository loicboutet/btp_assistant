# Routes for New UI Elements

This document lists all routes for the newly created views based on `doc/missing_ui_elements.md`.

## Client Area Routes

### Profile
- **List/View:** `/profile`
- **Named Route:** `client_profile_path`
- **Method:** GET
- **Controller#Action:** `profile#show`
- **View File:** `app/views/profile/show.html.erb`
- **Description:** User profile page showing personal info, business info, WhatsApp connection, and subscription details

### Quotes
- **List:** `/quotes`
- **Named Route:** `quotes_path`
- **Method:** GET
- **Controller#Action:** `quotes#index`
- **View File:** `app/views/quotes/index.html.erb`
- **Description:** List of all quotes with statistics and filters

- **Detail:** `/quotes/:id`
- **Named Route:** `quote_path(id)`
- **Method:** GET
- **Controller#Action:** `quotes#show`
- **View File:** `app/views/quotes/show.html.erb`
- **Description:** Individual quote detail with client info, line items, totals, and actions
- **Example:** `/quotes/1`

### Invoices
- **List:** `/invoices`
- **Named Route:** `invoices_path`
- **Method:** GET
- **Controller#Action:** `invoices#index`
- **View File:** `app/views/invoices/index.html.erb`
- **Description:** List of all invoices with statistics and filters

- **Detail:** `/invoices/:id`
- **Named Route:** `invoice_path(id)`
- **Method:** GET
- **Controller#Action:** `invoices#show`
- **View File:** `app/views/invoices/show.html.erb`
- **Description:** Individual invoice detail with payment status, client info, and payment tracking
- **Example:** `/invoices/1`

### Clients
- **List:** `/clients`
- **Named Route:** `clients_path`
- **Method:** GET
- **Controller#Action:** `clients#index`
- **View File:** `app/views/clients/index.html.erb`
- **Description:** List of all clients with contact details and statistics

- **Detail:** `/clients/:id`
- **Named Route:** `client_path(id)`
- **Method:** GET
- **Controller#Action:** `clients#show`
- **View File:** `app/views/clients/show.html.erb`
- **Description:** Individual client detail with recent quotes, invoices, and statistics
- **Example:** `/clients/1`

### Conversations
- **List:** `/conversations`
- **Named Route:** `conversations_path`
- **Method:** GET
- **Controller#Action:** `conversations#index`
- **View File:** `app/views/conversations/index.html.erb`
- **Description:** WhatsApp conversation history with filters and status tracking

## Admin Area Routes

### Users Management
- **List:** `/admin/users`
- **Named Route:** `admin_users_path`
- **Method:** GET
- **Controller#Action:** `admin/users#index`
- **View File:** `app/views/admin/users/index.html.erb`
- **Description:** List of all users with filters and search

- **New:** `/admin/users/new`
- **Named Route:** `new_admin_user_path`
- **Method:** GET
- **Controller#Action:** `admin/users#new`
- **View File:** `app/views/admin/users/new.html.erb`
- **Description:** Form to create a new user account

- **Create:** `/admin/users`
- **Named Route:** `admin_users_path`
- **Method:** POST
- **Controller#Action:** `admin/users#create`
- **Description:** Submit new user creation form

- **Edit:** `/admin/users/:id/edit`
- **Named Route:** `edit_admin_user_path(id)`
- **Method:** GET
- **Controller#Action:** `admin/users#edit`
- **View File:** `app/views/admin/users/edit.html.erb`
- **Description:** Form to edit existing user account
- **Example:** `/admin/users/1/edit`

- **Update:** `/admin/users/:id`
- **Named Route:** `admin_user_path(id)`
- **Method:** PATCH
- **Controller#Action:** `admin/users#update`
- **Description:** Submit user update form

- **Show:** `/admin/users/:id`
- **Named Route:** `admin_user_path(id)`
- **Method:** GET
- **Controller#Action:** `admin/users#show`
- **View File:** `app/views/admin/users/show.html.erb`
- **Description:** View user details (already existed)
- **Example:** `/admin/users/1`

## Quick Reference Table

| View Type | URL Pattern | View File | Named Route Helper |
|-----------|-------------|-----------|-------------------|
| **Client Area** |
| Profile | `/profile` | `profile/show.html.erb` | `client_profile_path` |
| Quotes List | `/quotes` | `quotes/index.html.erb` | `quotes_path` |
| Quote Detail | `/quotes/:id` | `quotes/show.html.erb` | `quote_path(id)` |
| Invoices List | `/invoices` | `invoices/index.html.erb` | `invoices_path` |
| Invoice Detail | `/invoices/:id` | `invoices/show.html.erb` | `invoice_path(id)` |
| Clients List | `/clients` | `clients/index.html.erb` | `clients_path` |
| Client Detail | `/clients/:id` | `clients/show.html.erb` | `client_path(id)` |
| Conversations | `/conversations` | `conversations/index.html.erb` | `conversations_path` |
| **Admin Area** |
| Users List | `/admin/users` | `admin/users/index.html.erb` | `admin_users_path` |
| User New | `/admin/users/new` | `admin/users/new.html.erb` | `new_admin_user_path` |
| User Edit | `/admin/users/:id/edit` | `admin/users/edit.html.erb` | `edit_admin_user_path(id)` |

## Testing the Routes

You can test these routes by:

1. Starting the Rails server:
   ```bash
   rails server
   ```

2. Visiting the URLs in your browser (authentication required):
   - Client Area: http://localhost:3000/profile
   - Quotes: http://localhost:3000/quotes
   - Quote Detail: http://localhost:3000/quotes/1
   - Invoices: http://localhost:3000/invoices
   - Invoice Detail: http://localhost:3000/invoices/1
   - Clients: http://localhost:3000/clients
   - Client Detail: http://localhost:3000/clients/1
   - Conversations: http://localhost:3000/conversations
   - Admin Users: http://localhost:3000/admin/users
   - Admin User New: http://localhost:3000/admin/users/new
   - Admin User Edit: http://localhost:3000/admin/users/1/edit

3. Using Rails console to generate paths:
   ```ruby
   Rails.application.routes.url_helpers.client_profile_path
   Rails.application.routes.url_helpers.quote_path(1)
   Rails.application.routes.url_helpers.new_admin_user_path
   ```

## Navigation

All client area routes are accessible via the client layout navigation menu:
- Dashboard → Devis → Factures → Clients → Conversations → Profile (dropdown)

Admin routes are managed separately through the admin layout.

## Notes

- All routes require authentication (user must be signed in)
- Admin routes require admin privileges
- Detail routes (show pages) use IDs in the URL - you'll need actual database records to view them
- The dummy data in the listing pages uses IDs 1-5 for demonstration purposes
