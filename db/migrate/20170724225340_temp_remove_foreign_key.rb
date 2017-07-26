class TempRemoveForeignKey < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key "stories", column: "author"
  end
end
