class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def add_unless_present(col, obj)
    already_in = col.include?(obj)
    col << obj unless already_in
    !already_in
  end
end
