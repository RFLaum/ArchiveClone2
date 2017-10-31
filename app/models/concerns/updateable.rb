module Updateable
  extend ActiveSupport::Concern

  def updated?
    created_at != updated_at
  end
  
end
