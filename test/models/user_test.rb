require "test_helper"
require "ostruct"
require "stringio"

class UserTest < ActiveSupport::TestCase
  def build_uploaded_file_for(user)
    uploaded_file = UploadedFile.new(
      user: user,
      filename: "example.txt",
      content_type: "text/plain",
      file_size: 5,
      expires_at: 2.days.from_now,
      share_type: :private
    )
    uploaded_file.file.attach(io: StringIO.new("hello"), filename: "example.txt", content_type: "text/plain")
    uploaded_file
  end

  test "is valid with fixture attributes" do
    user = User.find_by!(provider: "entra", uid: "user-1")

    assert user.valid?
  end

  test "requires provider uid and email" do
    user = User.new(name: "No Provider")

    assert_not user.valid?
    assert_includes user.errors[:provider], "can't be blank"
    assert_includes user.errors[:uid], "can't be blank"
    assert_includes user.errors[:email], "can't be blank"
  end

  test "validates theme_preference inclusion" do
    user = User.new(
      provider: "entra_id",
      uid: "theme-test-user",
      email: "theme-test@example.com",
      name: "Theme Test",
      theme_preference: "solarized"
    )

    assert_not user.valid?
    assert_includes user.errors[:theme_preference], "is not included in the list"
  end

  test "enforces uid uniqueness scoped to provider" do
    existing = User.find_by!(provider: "entra", uid: "user-1")
    duplicate = User.new(
      provider: existing.provider,
      uid: existing.uid,
      email: "duplicate@example.com",
      name: "Duplicate"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:uid], "has already been taken"
  end

  test "allows same uid for a different provider" do
    user = User.new(
      provider: "google",
      uid: "user-1",
      email: "google-user@example.com",
      name: "Google User"
    )

    assert user.valid?
  end

  test "destroys uploaded_files when user is destroyed" do
    user = User.create!(
      provider: "entra_id",
      uid: "dependent-test-user",
      email: "dependent-test@example.com",
      name: "Dependent Test"
    )
    uploaded_file = build_uploaded_file_for(user)
    uploaded_file.save!

    assert_difference("UploadedFile.count", -1) do
      user.destroy
    end
  end

  test "from_omniauth creates a new user" do
    auth = OpenStruct.new(
      provider: "entra_id",
      uid: "omniauth-create-user",
      info: OpenStruct.new(name: "Omni New", email: "omniauth-new@example.com")
    )

    assert_difference("User.count", 1) do
      user = User.from_omniauth(auth)
      assert user.persisted?
      assert_equal "Omni New", user.name
      assert_equal "omniauth-new@example.com", user.email
    end
  end

  test "from_omniauth returns existing user without creating duplicate" do
    existing = User.create!(
      provider: "entra_id",
      uid: "omniauth-existing-user",
      email: "existing@example.com",
      name: "Existing User"
    )
    auth = OpenStruct.new(
      provider: existing.provider,
      uid: existing.uid,
      info: OpenStruct.new(name: "Changed Name", email: "changed@example.com")
    )

    assert_no_difference("User.count") do
      user = User.from_omniauth(auth)
      assert_equal existing.id, user.id
      assert_equal "Existing User", user.name
      assert_equal "existing@example.com", user.email
    end
  end
end
