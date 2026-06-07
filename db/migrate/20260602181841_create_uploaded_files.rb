class CreateUploadedFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :uploaded_files do |t|
      t.string :filename, null: false
      t.string :content_type, null: false
      t.integer :file_size, null: false
      t.string :upload_uuid, null: false
      t.datetime :expires_at, null: false
      t.integer :share_type, null: false, default: 0
      t.timestamps
    end
  end
end
