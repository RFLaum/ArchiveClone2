class FixJoinTableTagName < ActiveRecord::Migration[5.0]
  def change
    change_table :stories_tags do |t|
      t.rename :tag, :name
    end
  end
end
