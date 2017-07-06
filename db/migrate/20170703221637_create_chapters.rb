class CreateChapters < ActiveRecord::Migration[5.0]
  def change
    create_table :chapters do |t|
      t.integer :story, null: false
      t.integer :number, null: false
      t.string :title
      t.text :body, null: false

      t.timestamps
    end
  end
end
