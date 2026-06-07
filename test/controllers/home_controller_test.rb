require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests to login" do
    get root_url
    assert_redirected_to login_url
    assert_equal "You must be logged in to access this page.", flash[:alert]
  end
end
