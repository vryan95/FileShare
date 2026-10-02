class CreateEntraSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :entra_settings do |t|
      t.string :client_id, null: false
      t.string :client_secret, null: false
      t.string :tenant_id, null: false

      t.timestamps
    end
  end
end
