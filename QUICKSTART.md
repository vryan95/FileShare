# Entra ID Authentication - Quick Start

## What Was Implemented

✅ User model with Entra ID authentication
✅ OmniAuth configuration for Microsoft Entra ID
✅ Session management (login/logout)
✅ Authentication helpers (`current_user`, `logged_in?`, `require_login`)
✅ Login page with Microsoft sign-in button
✅ Example home page showing authenticated user info
✅ Proper route configuration

## Quick Setup (3 Steps)

### 1. Azure Portal Configuration

1. Go to [Azure Portal](https://portal.azure.com) → **Microsoft Entra ID** → **App registrations**
2. Click **New registration**
3. Set redirect URI: `http://localhost:3000/auth/entra_id/callback`
4. Copy:
   - Application (client) ID
   - Directory (tenant) ID
   - Create a Client Secret and copy its value


### 2. Configure Environment Variables

**Important:** The `dotenv-rails` gem has been added to load environment variables from `.env` file in development.

Create a `.env` file (copy from `.env.example`):

```bash
cp .env.example .env
```

Edit `.env` and add your credentials:

```env
ENTRA_CLIENT_ID=your_client_id_here
ENTRA_CLIENT_SECRET=your_client_secret_here
ENTRA_TENANT_ID=common
```

### 3. Start the Application

```bash
# Install dependencies (if needed)
bundle install

# Run migrations (already done)
# rails db:migrate

# Start server
rails server
```

Visit: http://localhost:3000

## Testing Authentication

1. Go to http://localhost:3000
2. Click "Sign In"
3. You'll be redirected to Microsoft login
4. Sign in with your Microsoft account
5. After successful authentication, you'll see your profile info

## Using Authentication in Your App

### Protect a Controller Action

```ruby
class YourController < ApplicationController
  before_action :require_login  # Require authentication for all actions
  
  # Or protect specific actions:
  before_action :require_login, only: [:edit, :update, :destroy]
  
  def index
    # Only authenticated users can access this
  end
end
```

### Check Authentication in Views

```erb
<% if logged_in? %>
  <p>Welcome, <%= current_user.name %>!</p>
  <p>Email: <%= current_user.email %></p>
  <%= button_to "Logout", logout_path, method: :delete %>
<% else %>
  <%= link_to "Login", login_path %>
<% end %>
```

### Access Current User in Controllers

```ruby
def some_action
  if logged_in?
    user = current_user
    # user.name, user.email, user.provider, user.uid
  end
end
```

## Files Modified/Created

### Models
- `app/models/user.rb` - User model with Entra ID integration
- `db/migrate/XXXXXX_create_users.rb` - Users table migration

### Controllers
- `app/controllers/application_controller.rb` - Added authentication helpers
- `app/controllers/sessions_controller.rb` - Handles login/logout
- `app/controllers/home_controller.rb` - Example controller

### Views
- `app/views/sessions/new.html.erb` - Login page
- `app/views/home/index.html.erb` - Example authenticated page

### Configuration
- `config/initializers/omniauth.rb` - OmniAuth Entra ID configuration
- `config/routes.rb` - Authentication routes

### Documentation
- `.env.example` - Environment variables template
- `ENTRA_AUTH_SETUP.md` - Detailed setup instructions
- `QUICKSTART.md` - This file

## Available Routes

- `GET /` - Home page (shows authentication status)
- `GET /login` - Login page
- `POST /auth/entra_id` - Initiate Microsoft sign-in
- `GET/POST /auth/entra_id/callback` - OAuth callback
- `DELETE /logout` - Logout
- `GET /auth/failure` - Authentication error handler

## Troubleshooting

### Sign-in button just refreshes the page
- **Cause**: Environment variables not loading
- **Solution**: Make sure `dotenv-rails` gem is installed (`bundle install`) and restart your Rails server
- Check if `.env` file exists and contains your credentials
- Verify variables are loaded: `rails runner "puts ENV['ENTRA_CLIENT_ID']"`

### "Redirect URI mismatch" error
- Ensure the callback URL in Azure Portal matches exactly: `http://localhost:3000/auth/entra_id/callback`

### "Invalid client secret" error  
- Check that you copied the secret value (not the secret ID)
- Verify the secret hasn't expired in Azure Portal

### Can't access current_user
- Make sure you've logged in successfully
- Check that session[:user_id] is being set in SessionsController

### "You must provide either client_secret or certificate_path and tenant_id"
- Environment variables are not being loaded properly
- Ensure `dotenv-rails` gem is installed
- Restart the Rails server after adding/modifying `.env`
- Check that your `.env` file has the correct format (no quotes around values)

## Next Steps

1. **Protect your controllers**: Add `before_action :require_login` to controllers that need authentication
2. **Customize views**: Update the login page and home page to match your design
3. **Add user roles**: Extend the User model with roles/permissions if needed
4. **Production setup**: Configure production environment variables and update callback URLs

For detailed instructions, see `ENTRA_AUTH_SETUP.md`
