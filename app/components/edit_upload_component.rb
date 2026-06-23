class EditUploadComponent < ViewComponent::Base
  def initialize(uploaded_file:)
    @uploaded_file = uploaded_file
  end

  private

  attr_reader :uploaded_file

  def modal_id
    "editFileModal-#{uploaded_file.upload_uuid}"
  end

  def expires_at_value
    uploaded_file.expires_at.to_date.strftime("%d/%m/%Y")
  end

  def share_type_options
    UploadedFile.share_types.keys.map do |share_type|
      [ I18n.t("share_types.#{share_type}"), share_type ]
    end
  end
end
