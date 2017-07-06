class MakeSummaryNotNull < ActiveRecord::Migration[5.0]
  def change
    create_table :stories, force: true do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.text :summary, limit: 500

      t.timestamps
    end
  end
end
