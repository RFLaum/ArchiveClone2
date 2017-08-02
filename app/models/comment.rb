class Comment < ApplicationRecord
  belongs_to :user, foreign_key: 'author', primary_key: 'name'
  belongs_to :story

  # todo: worry about validations later
  # validates :author, presence: true

  def updated?
    created_at != updated_at
  end
end
