class UpdateSubs < ActiveRecord::Migration[5.0]
  def change
    add_column :subscriptions, :writer_name, :string
    add_column :subscriptions, :reader_name, :string
    remove_column :subscriptions, :updated_at, :datetime
    remove_column :subscriptions, :created_at, :datetime

    add_index :subscriptions, :writer_name
    add_index :subscriptions, :reader_name
  end
end
