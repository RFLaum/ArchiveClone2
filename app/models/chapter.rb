class Chapter < ApplicationRecord
  belongs_to :story

  def get_title
    title.to_s
  end

  def tags
    # story.tags
    ''
  end

  # todo: does this work if the story's being newly created?
  def tags=(tag_string)
    tag_array = tag_string.split(/,\s*/)
    story.add_tags(tag_array)
  end
end
