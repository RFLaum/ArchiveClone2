class CreateNewsImplications < ActiveRecord::Migration[5.0]
  def change
    create_table :news_implications do |t|
      t.integer :implier_id
      t.integer :implied_id
    end

    add_index :news_implications, %i[implier_id implied_id], unique: true
    add_index :news_implications, :implied_id
  end
end
