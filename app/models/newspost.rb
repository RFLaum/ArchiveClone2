class Newspost < ApplicationRecord
  include Updateable
  include Taggable
  belongs_to :user, foreign_key: 'admin', primary_key: 'name'
  has_and_belongs_to_many :news_tags

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

  private

  def get_tags(type = nil)
    news_tags
  end

  def tag_class(type = nil)
    NewsTag
  end
end
