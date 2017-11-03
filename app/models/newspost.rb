class Newspost < ApplicationRecord
  include Updateable
  include Taggable
  include Commentable
  belongs_to :user, foreign_key: 'admin', primary_key: 'name'
  has_and_belongs_to_many :news_tags
  has_many :comments, class_name: 'NewsComment', dependent: :destroy

  # after_initialize do |post|
  #   @tags = news_tags
  #   @tag_class = NewsTag
  # end

  def first_paragraph
    Nokogiri::HTML.parse(content).at_xpath('//p').text
  end

  def display_name
    title
  end

  def comment_edit_helper
    :edit_newspost_news_comment_path
  end

  private

  def get_tags(type = nil)
    news_tags
  end

  def tag_class(type = nil)
    NewsTag
  end
end
