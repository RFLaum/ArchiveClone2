class TempRemoveSecond < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key "chapters", "stories"
  end
end
