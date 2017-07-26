class AddForeignKeyToChapters < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :chapters, :stories
  end
end
