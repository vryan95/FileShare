class AddUserToUploadedFile < ActiveRecord::Migration[8.1]
  def change
    add_reference :uploaded_files, :user, null: false, foreign_key: true
  end
end
