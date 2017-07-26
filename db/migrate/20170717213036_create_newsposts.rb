class CreateNewsposts < ActiveRecord::Migration[5.0]
  def change
    create_table :newsposts do |t|
      t.string :admin_name
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
