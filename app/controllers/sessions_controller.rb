class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  layout "signed_out"

  rate_limit to: 10, within: 3.minutes, only: :authenticate, with: -> { redirect_to login_path, alert: t("sessions.authenticate.rate_limited") }

  def new
    @entra_configured = EntraSetting.configured?
  end

  # Email and password sign-in.
  def authenticate
    if (user = User.authenticate_by(email: params[:email], password: params[:password]))
      start_session_for(user)
      redirect_to root_path, notice: "Successfully authenticated!"
    else
      redirect_to login_path, alert: t(".invalid")
    end
  end

  # Entra ID (OmniAuth) callback.
  def create
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)

    if user.persisted?
      start_session_for(user)
      redirect_to root_path, notice: "Successfully authenticated!"
    else
      redirect_to login_path, alert: "Authentication failed. Please try again."
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out successfully."
  end

  def failure
    redirect_to login_path, alert: "Authentication failed: #{params[:message]}"
  end
end
