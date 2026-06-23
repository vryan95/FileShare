require "test_helper"
require "stringio"

class UploadedFileTest < ActiveSupport::TestCase
  def fixture_user
    User.find_by!(provider: "entra", uid: "user-1")
  end

  def build_uploaded_file(overrides = {})
    attrs = {
      user: fixture_user,
      filename: "upload.txt",
      content_type: "text/plain",
      file_size: 5,
      expires_at: 2.days.from_now,
      share_type: :private
    }.merge(overrides)

    uploaded_file = UploadedFile.new(attrs)
    uploaded_file.file.attach(io: StringIO.new("hello"), filename: "upload.txt", content_type: "text/plain")
    uploaded_file
  end

  test "is valid with required attributes and attached file" do
    uploaded_file = build_uploaded_file

    assert uploaded_file.valid?
  end

  test "requires attached file" do
    uploaded_file = UploadedFile.new(
      user: fixture_user,
      filename: "upload.txt",
      content_type: "text/plain",
      file_size: 5,
      expires_at: 2.days.from_now,
      share_type: :private
    )

    assert_not uploaded_file.valid?
    assert_includes uploaded_file.errors[:file], "can't be blank"
  end

  test "requires core metadata attributes" do
    uploaded_file = build_uploaded_file(
      filename: nil,
      content_type: nil,
      file_size: nil,
      expires_at: nil
    )

    assert_not uploaded_file.valid?
    assert_includes uploaded_file.errors[:filename], "can't be blank"
    assert_includes uploaded_file.errors[:content_type], "can't be blank"
    assert_includes uploaded_file.errors[:file_size], "can't be blank"
    assert_includes uploaded_file.errors[:expires_at], "can't be blank"
  end

  test "generates upload_uuid before create when missing" do
    uploaded_file = build_uploaded_file(upload_uuid: nil)

    uploaded_file.save!

    assert uploaded_file.upload_uuid.present?
    assert_match(/\A[0-9a-f\-]{36}\z/, uploaded_file.upload_uuid)
  end

  test "does not override an existing upload_uuid" do
    uploaded_file = build_uploaded_file(upload_uuid: "33333333-3333-3333-3333-333333333333")

    uploaded_file.save!

    assert_equal "33333333-3333-3333-3333-333333333333", uploaded_file.upload_uuid
  end

  test "to_param returns upload_uuid" do
    uploaded_file = build_uploaded_file(upload_uuid: "44444444-4444-4444-4444-444444444444")

    assert_equal "44444444-4444-4444-4444-444444444444", uploaded_file.to_param
  end

  test "share_type enum exposes predicate and bang methods" do
    uploaded_file = build_uploaded_file(share_type: :private)

    assert uploaded_file.share_type_private?
    uploaded_file.share_type_internal!
    assert uploaded_file.share_type_internal?
    uploaded_file.share_type_public!
    assert uploaded_file.share_type_public?
  end
end
