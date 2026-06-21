# frozen_string_literal: true

class UploadDropzoneComponent < ViewComponent::Base
  def initialize(uploaded_file:)
    @uploaded_file = uploaded_file
  end

  private

  def expires_at_value
    (@uploaded_file.expires_at || 2.days.from_now).to_date.strftime("%d/%m/%Y")
  end

  def share_type_options
    UploadedFile.share_types.keys.map do |share_type|
      [ I18n.t("share_types.#{share_type}"), share_type ]
    end
  end
end
