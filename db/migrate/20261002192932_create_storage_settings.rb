class CreateStorageSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :storage_settings do |t|
      t.string :service, null: false, default: "local"
      t.string :azure_storage_account_name
      t.string :azure_storage_access_key
      t.string :azure_container

      t.timestamps
    end
  end
end
