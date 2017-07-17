class AddAdultToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :adult, :boolean
  end
end
