class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users, id: false do |t|
      t.string :name, null: false, unique: true
      t.string :email, null: false
      t.string :password_digest
      t.index :name, unique: true

      t.timestamps
    end
  end
end
