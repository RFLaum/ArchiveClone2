class Bookmark < ApplicationRecord
  include Updateable
  belongs_to :user, foreign_key: 'user_name', primary_key: 'name'
  belongs_to :story

  #filters a set of bookmarks to get only the ones visible by a given user
  #TODO: check this
  def self.visible_filter(mark_set, viewing_user)
    first = mark_set.where(private: false)
    second = mark_set.where(user: viewing_user)
    first.or(second)
  end

  def to_partial_path
    'bookmarks/summary'
  end
end
