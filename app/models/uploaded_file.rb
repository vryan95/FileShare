class UploadedFile < ApplicationRecord
  has_one_attached :file

  validates :file, presence: true
end
