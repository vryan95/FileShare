# frozen_string_literal: true

require "test_helper"

class UploadDropzoneComponentTest < ViewComponent::TestCase
  def test_renders_form_with_share_type_and_expiration_value
    user = User.create!(
      provider: "entra_id",
      uid: "upload-test-user",
      name: "Upload User",
      email: "upload-user@example.com",
      theme_preference: "light"
    )
    uploaded_file = UploadedFile.new(user:, expires_at: Date.new(2030, 1, 2), share_type: :private)

    render_inline(UploadDropzoneComponent.new(uploaded_file:))

    assert_selector "form.upload-dropzone-form[data-controller='upload-dropzone']"
    assert_selector "select[name='uploaded_file[share_type]'] option[value='private']", text: I18n.t("share_types.private")
    assert_selector "select[name='uploaded_file[share_type]'] option[value='internal']", text: I18n.t("share_types.internal")
    assert_selector "select[name='uploaded_file[share_type]'] option[value='public']", text: I18n.t("share_types.public")
    assert_selector "input[name='uploaded_file[expires_at]'][value='02/01/2030']"
  end

  def test_renders_dropzone_and_submit_in_initial_state
    user = User.create!(
      provider: "entra_id",
      uid: "upload-test-user-2",
      name: "Upload User Two",
      email: "upload-user-2@example.com",
      theme_preference: "light"
    )
    uploaded_file = UploadedFile.new(user:)

    render_inline(UploadDropzoneComponent.new(uploaded_file:))

    assert_selector ".upload-dropzone[role='button'][tabindex='0']"
    assert_selector "input[type='file'].visually-hidden[name='uploaded_file[file]'][accept='*/*']"
    assert_selector ".upload-dropzone__progress.d-none"
    assert_selector "input[type='submit'][disabled]"
  end
end
