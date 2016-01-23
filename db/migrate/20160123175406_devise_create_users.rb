class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :bitcoin_address, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.boolean :active , default: false

      ## Rememberable
      t.datetime :remember_created_at



      t.timestamps null: false
    end

    add_index :users, :bitcoin_address,                unique: true
  end
end
