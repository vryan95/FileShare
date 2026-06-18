# frozen_string_literal: true

class UploadDropzoneComponent < ViewComponent::Base
  def initialize(uploaded_file:)
    @uploaded_file = uploaded_file
  end
end
