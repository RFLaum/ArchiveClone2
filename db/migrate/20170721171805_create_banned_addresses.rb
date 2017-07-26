class CreateBannedAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :banned_addresses, id: false do |t|
      t.string :email, null: false

      # t.timestamps
    end
    add_index :banned_addresses, :email, unique: true
  end
end
