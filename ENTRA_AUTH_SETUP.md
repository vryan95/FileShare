# Entra ID Authentication Setup

This application uses Microsoft Entra ID (formerly Azure AD) for authentication via OmniAuth.

## Prerequisites

1. A Microsoft Entra ID (Azure AD) tenant
2. An app registration in the Azure Portal

## Azure Portal Setup

### 1. Register an Application

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Microsoft Entra ID** > **App registrations**
3. Click **New registration**
4. Configure:
   - **Name**: FileShare (or your app name)
   - **Supported account types**: Choose based on your needs
     - Single tenant: Only users in your organization
     - Multitenant: Users from any organization
     - Accounts and personal Microsoft accounts
   - **Redirect URI**: 
     - Type: Web
     - URL: `http://localhost:3000/auth/entra_id/callback` (for development)
     - For production: `https://yourdomain.com/auth/entra_id/callback`

### 2. Get Your Credentials

After registration:

1. **Application (client) ID**: Copy this from the Overview page
2. **Directory (tenant) ID**: Copy this from the Overview page
3. **Client Secret**: 
   - Go to **Certificates & secrets**
   - Click **New client secret**
   - Add a description and set expiration
   - **Copy the Value immediately** (you won't be able to see it again!)

### 3. Configure API Permissions (Optional but Recommended)

1. Go to **API permissions**
2. Click **Add a permission**
3. Select **Microsoft Graph**
4. Choose **Delegated permissions**
5. Add:
   - `User.Read` (to read basic user profile)
   - `email` (to access user email)
   - `profile` (to access user profile info)
6. Click **Grant admin consent** if you're an admin

## Application Setup

### 1. Install Dependencies

```bash
bundle install
```

### 2. Configure Environment Variables

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and add your Entra ID credentials:

```env
ENTRA_CLIENT_ID=your_application_client_id
ENTRA_CLIENT_SECRET=your_client_secret_value
ENTRA_TENANT_ID=your_tenant_id  # or use "common" for multi-tenant
```

**Tenant ID Options:**
- `common`: Allows any Microsoft account (personal or organizational)
- `organizations`: Allows any organizational account
- `consumers`: Allows only personal Microsoft accounts
- `<tenant-id>`: Restricts to your specific organization

### 3. Run Migrations

```bash
rails db:migrate
```

### 4. Start the Server

```bash
rails server
```

### 5. Test Authentication

1. Visit `http://localhost:3000/login`
2. Click "Sign in with Microsoft"
3. You'll be redirected to Microsoft's login page
4. After successful authentication, you'll be redirected back to your app

## Usage in Controllers

### Protect Actions with Authentication

```ruby
class YourController < ApplicationController
  before_action :require_login
  
  def index
    # Only logged-in users can access this
  end
end
```

### Check if User is Logged In

```ruby
# In controllers
if logged_in?
  # User is authenticated
end

# Access current user
current_user.name
current_user.email
```

### In Views

```erb
<% if logged_in? %>
  <p>Welcome, <%= current_user.name %>!</p>
  <%= button_to "Logout", logout_path, method: :delete %>
<% else %>
  <%= link_to "Login", login_path %>
<% end %>
```

## Routes

- `GET /login` - Login page
- `POST /auth/entra_id` - Initiate Entra ID authentication
- `GET/POST /auth/entra_id/callback` - OAuth callback
- `DELETE /logout` - Logout
- `GET /auth/failure` - Authentication failure handler

## Troubleshooting

### Redirect URI Mismatch
- Ensure the callback URL in Azure Portal matches exactly: `http://localhost:3000/auth/entra_id/callback`
- For production, update to your production URL

### Invalid Client Secret
- Client secrets expire - check the expiration date in Azure Portal
- Generate a new secret if expired

### CSRF Token Issues
- The SessionsController skips CSRF verification for the callback
- Ensure `omniauth-rails_csrf_protection` gem is installed

### Common Tenant ID Issues
- Using "common" allows any Microsoft account
- Using your specific tenant ID restricts to your organization only
- Make sure the user's account type matches your app registration settings

## Security Notes

1. **Never commit `.env` to version control** - it contains secrets
2. Add `.env` to your `.gitignore`
3. Use different credentials for development and production
4. Rotate client secrets regularly
5. Use environment variables or secure vaults in production (e.g., Rails credentials, Azure Key Vault)

## Production Deployment

For production:

1. Update redirect URI in Azure Portal to your production domain
2. Use environment variables or Rails encrypted credentials
3. Consider using a secret management service
4. Enable HTTPS (required by OAuth2)
