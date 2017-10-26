class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  #returns true if added, false if not added
  def add_unless_present(col, obj)
    # if obj.is_a? Tag
    #   logger.debug "aup test"
    #   logger.debug obj.attributes.to_s
    #   col.each do |h|
    #     logger.debug h.attributes.to_s
    #   end
    # end
    already_in = col.include?(obj)
    col << obj unless already_in
    # if obj.is_a? Tag
    #   logger.debug "already_in = #{already_in}"
    # end
    !already_in
  end
end
