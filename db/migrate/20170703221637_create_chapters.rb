class CreateChapters < ActiveRecord::Migration[5.0]
  def change
    create_table :chapters, id: false do |t|
      t.integer :story, null: false
      t.integer :number, null: false
      t.string :title
      t.text :body, null: false

      t.timestamps
      # execute "ALTER TABLE chapters ADD PRIMARY KEY (story_id, number)"
    end
  end
end
