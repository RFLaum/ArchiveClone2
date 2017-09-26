class CreateBookmarks < ActiveRecord::Migration[5.0]
  def change
    create_table :bookmarks do |t|
      t.string :user_name
      t.integer :story_id
      t.boolean :private, default: false
      t.text :user_notes

      t.timestamps
    end

    add_index :bookmarks, %i[user_name story_id], unique: true
    add_index :bookmarks, :story_id
  end
end
