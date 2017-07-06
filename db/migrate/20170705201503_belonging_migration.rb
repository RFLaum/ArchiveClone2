class BelongingMigration < ActiveRecord::Migration[5.0]
  def change
    create_table :chapters, force: true do |t|
      # t.integer :story_id, null: false
      t.belongs_to :story, index: true
      t.integer :number, null: false
      t.string :title
      t.text :body, null: false

      t.timestamps
    end

    create_table :characters, force: true do |t|
      t.belongs_to :source, index: true
      t.string :name, null: false
    end
  end
end
