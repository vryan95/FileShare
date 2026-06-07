class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  layout "signed_out"

  def new
    # Login page - will have link to trigger Entra ID auth
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)

    if user.persisted?
      session[:user_id] = user.id
      redirect_to root_path, notice: "Successfully authenticated!"
    else
      redirect_to login_path, alert: "Authentication failed. Please try again."
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out successfully."
  end

  def failure
    redirect_to login_path, alert: "Authentication failed: #{params[:message]}"
  end
end
