class RestoreForeignKey < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :stories, :users, column: :author, primary_key: :name
  end
end
