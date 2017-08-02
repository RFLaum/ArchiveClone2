class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.string :author, null: false
      t.integer :story_id, null: false
      t.text :content, null: false

      t.timestamps

      t.index :story_id
      t.index :author
    end

    add_foreign_key :comments, :users, column: :author, primary_key: :name
    add_foreign_key :comments, :stories
  end
end
