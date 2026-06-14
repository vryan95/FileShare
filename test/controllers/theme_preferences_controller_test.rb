require "test_helper"

class ThemePreferencesControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when not authenticated" do
    patch theme_preference_path, params: { theme: "dark" }

    assert_redirected_to login_path
  end

  test "updates theme preference for authenticated user" do
    user = users(:one)

    patch theme_preference_path,
          params: { theme: "dark" },
          env: { "rack.session" => { user_id: user.id } }

    assert_redirected_to root_path
    assert_equal "dark", user.reload.theme_preference
  end

  test "rejects invalid theme values" do
    user = users(:one)

    patch theme_preference_path,
          params: { theme: "neon" },
          env: { "rack.session" => { user_id: user.id } }

    assert_redirected_to root_path
    assert_equal "light", user.reload.theme_preference
  end
end
