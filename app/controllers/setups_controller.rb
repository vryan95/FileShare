# First-run setup: creates the first account (an admin) when the database has no users yet.
class SetupsController < ApplicationController
  skip_before_action :require_setup
  before_action :redirect_if_set_up
  layout "signed_out"

  rate_limit to: 10, within: 3.minutes, only: :create

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(admin: true))

    if @user.save
      start_session_for(@user)
      redirect_to root_path, notice: t(".created")
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def redirect_if_set_up
    redirect_to root_path if User.exists?
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
