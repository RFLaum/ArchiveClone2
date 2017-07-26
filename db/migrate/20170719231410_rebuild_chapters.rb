class RebuildChapters < ActiveRecord::Migration[5.0]
  def change
    drop_table :chapters
    create_table :chapters, id: false do |t|
      t.integer "number", null: false
      t.string "title"
      t.text "body", null: false

      t.timestamps
    end
    add_column :chapters, :story_id, :integer
    change_column_null :chapters, :story_id, false
    add_foreign_key :chapters, :stories
  end
end
