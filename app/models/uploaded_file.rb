class UploadedFile < ApplicationRecord
  has_one_attached :file

  validates :file, presence: true
  validates :filename, :content_type, :file_size, :expires_at, presence: true

  before_create :generate_uuid

  enum :share_type, { private: 0, internal: 1, public: 2 }, prefix: true

  private

  def generate_uuid
    self.upload_uuid ||= SecureRandom.uuid
  end
end
