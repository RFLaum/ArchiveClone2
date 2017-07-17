class AddAdultOverrideToStories < ActiveRecord::Migration[5.0]
  def change
    add_column :stories, :adult_override, :boolean
  end
end
