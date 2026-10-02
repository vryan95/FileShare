require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get login_url
    assert_response :success
    assert_select "input[name=password]"
  end

  test "shows the Microsoft button only when Entra is configured" do
    original = ENV.slice("ENTRA_CLIENT_ID", "ENTRA_CLIENT_SECRET")
    ENV.delete("ENTRA_CLIENT_ID")
    ENV.delete("ENTRA_CLIENT_SECRET")
    get login_url
    assert_select "form[action='/auth/entra_id']", count: 0
    ENV.update(original)

    EntraSetting.create!(client_id: "client", client_secret: "secret", tenant_id: "tenant-guid")
    get login_url
    assert_select "form[action='/auth/entra_id']"
  end

  test "signs in with email and password" do
    User.create!(name: "Password User", email: "password-user@example.com", password: "correct horse battery")

    post login_url, params: { email: "Password-User@example.com", password: "correct horse battery" }

    assert_redirected_to root_path
    get root_url
    assert_response :success
  end

  test "rejects a wrong password" do
    User.create!(name: "Password User", email: "password-user@example.com", password: "correct horse battery")

    post login_url, params: { email: "password-user@example.com", password: "wrong password here" }

    assert_redirected_to login_path
    assert_equal "Invalid email or password.", flash[:alert]
    get root_url
    assert_redirected_to login_url
  end

  test "sso users cannot sign in with a password" do
    post login_url, params: { email: users(:one).email, password: "" }

    assert_redirected_to login_path
    assert_equal "Invalid email or password.", flash[:alert]
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
