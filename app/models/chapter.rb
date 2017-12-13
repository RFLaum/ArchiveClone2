class Chapter < ApplicationRecord
  include Updateable
  self.primary_keys = :story_id, :number
  belongs_to :story, touch: true

  validates :body, length: { in: 20..900000,
    too_short: "must be at least %{count} characters long",
    too_long: "must be at most %{count} characters long" }

  def get_title
    self.title.to_s
  end

  def chapter_title
    get_title
  end

  def chapter_title=(new_title)
    self.title = new_title
  end

  def tags
    # story.tags
    ''
  end

  # todo: does this work if the story's being newly created?
  def tags=(tag_string)
    # tag_array = tag_string.split(/,\s*/)
    # story.add_tags(tag_array)
    story.set_tag_string(tag_string)
  end

  def heading
    answer = "Chapter #{number}"
    answer += ": #{title}" unless title.empty?
    answer
  end

  def self.name_field
    :title
  end
end
