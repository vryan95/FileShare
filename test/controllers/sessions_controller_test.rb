require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get login_url
    assert_response :success
  end

  test "should route omniauth callback to create" do
    assert_routing(
      { method: "get", path: "/auth/entra_id/callback" },
      { controller: "sessions", action: "create", provider: "entra_id" }
    )

    assert_routing(
      { method: "post", path: "/auth/entra_id/callback" },
      { controller: "sessions", action: "create", provider: "entra_id" }
    )
  end

  test "should destroy session" do
    delete logout_url

    assert_redirected_to root_path
    assert_equal "Logged out successfully.", flash[:notice]
  end
end
