module Commentable
  extend ActiveSupport::Concern

  def get_comments
    comments.order("created_at ASC")
  end

  def get_dummy_comment(author)
    comments.build(author: author)
  end
end
