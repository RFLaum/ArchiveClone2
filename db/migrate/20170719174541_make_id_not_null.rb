class MakeIdNotNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null :chapters, :story_id, false
  end
end
