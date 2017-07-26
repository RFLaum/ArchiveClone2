class Newspost < ApplicationRecord
  has_and_belongs_to_many :news_tags

  def first_paragraph
    Nokogiri::HTML.parse(this.content).at_xpath('//p').text
  end
end
