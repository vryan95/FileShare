require "test_helper"

class ThemePreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.mock_auth[:entra_id] = nil
    OmniAuth.config.test_mode = false
  end

  def sign_in_user
    user = User.create!(
      provider: "entra_id",
      uid: "theme-user-1",
      name: "Theme User",
      email: "theme-user@example.com",
      theme_preference: "light"
    )

    OmniAuth.config.mock_auth[:entra_id] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: OmniAuth::AuthHash.new(name: user.name, email: user.email)
    )

    post "/auth/entra_id/callback"

    user
  end

  test "redirects to login when not authenticated" do
    patch theme_preference_path, params: { theme: "dark" }

    assert_redirected_to login_path
  end

  test "updates theme preference for authenticated user" do
    user = sign_in_user

    patch theme_preference_path, params: { theme: "dark" }

    assert_redirected_to root_path
    assert_equal "dark", user.reload.theme_preference
  end

  test "rejects invalid theme values" do
    user = sign_in_user

    patch theme_preference_path, params: { theme: "neon" }

    assert_redirected_to root_path
    assert_equal "light", user.reload.theme_preference
  end
end
