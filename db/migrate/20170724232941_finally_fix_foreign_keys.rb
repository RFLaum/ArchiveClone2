class FinallyFixForeignKeys < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key "stories", column: "author"
    add_foreign_key :chapters, :stories, on_delete: :cascade
    add_foreign_key :stories, :users, column: :author, primary_key: :name, on_delete: :cascade
  end
end
