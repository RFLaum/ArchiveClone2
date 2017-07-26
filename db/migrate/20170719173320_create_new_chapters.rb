class CreateNewChapters < ActiveRecord::Migration[5.0]
  def change
    create_table :chapters, id: false do |t|
      t.integer "number", null: false
      t.string "title"
      t.text "body", null: false

      t.timestamps
    end
  end
end
