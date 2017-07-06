class Story < ApplicationRecord
  has_and_belongs_to_many :sources
  has_and_belongs_to_many :tags
  has_many :chapters

  def num_chapters
    Chapter.where(story_id: id).count
  end

  def add_tags(new_tags)
    new_tags.each do |tag|
      tag = Tag.tr_to_sql(tag)
      tags << Tag.new(name: tag) unless tags.exists?( name: tag )
    end
  end
end
