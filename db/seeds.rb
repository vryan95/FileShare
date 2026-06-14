# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

UploadedFile.find_or_create_by!(filename: "Example File", content_type: "text/plain", file_size: 1234, expires_at: 1.week.from_now, share_type: :public)
UploadedFile.find_or_create_by!(filename: "Example File 2", content_type: "text/plain", file_size: 1234, expires_at: 1.week.from_now, share_type: :public)
UploadedFile.find_or_create_by!(filename: "Example File 3", content_type: "text/plain", file_size: 1234, expires_at: 1.week.from_now, share_type: :public)