require "test_helper"

class SetupsControllerTest < ActionDispatch::IntegrationTest
  def setup_params(overrides = {})
    { user: { name: "Admin", email: "admin@example.com", password: "correct horse battery", password_confirmation: "correct horse battery" }.merge(overrides) }
  end

  test "redirects to setup when there are no users" do
    UploadedFile.delete_all
    User.delete_all

    get root_url
    assert_redirected_to new_setup_url

    get login_url
    assert_redirected_to new_setup_url
  end

  test "creates the first user as an admin and signs them in" do
    UploadedFile.delete_all
    User.delete_all

    get new_setup_url
    assert_response :success

    assert_difference("User.count", 1) do
      post setup_url, params: setup_params
    end

    user = User.last
    assert user.admin?
    assert_nil user.provider
    assert_redirected_to root_url

    get root_url
    assert_response :success
  end

  test "re-renders the form with errors" do
    UploadedFile.delete_all
    User.delete_all

    assert_no_difference("User.count") do
      post setup_url, params: setup_params(password_confirmation: "something else entirely")
    end

    assert_response :unprocessable_content
  end

  test "is unavailable once a user exists" do
    get new_setup_url
    assert_redirected_to root_url

    assert_no_difference("User.count") do
      post setup_url, params: setup_params
    end
    assert_redirected_to root_url
  end
end
