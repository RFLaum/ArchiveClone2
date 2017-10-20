class Character < ApplicationRecord
  include Storycount
  belongs_to :source #, after_add: :update_stories
  has_and_belongs_to_many :stories

  # def update_stories(source)
  #   stories.each do |story|
  #     story.add_source(source)
  #   end
  # end
  def self.tr_to_sql(dirty)
    dirty
  end

  def implied_tags
    []
  end
end
