class AddNewsComments < ActiveRecord::Migration[5.0]
  def change
    create_table :news_comments do |t|
      t.string :author, index: true
      t.integer :newspost_id, index: true
      t.text :content
      t.timestamps
    end
  end
end
