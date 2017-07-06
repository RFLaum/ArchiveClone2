class Chapter < ApplicationRecord
  belongs_to :story

  def tags
    story.tags
  end

  def tags=(tag_string)
    tag_array = tag_string.split(/,\s*/)
    story.add_tags(tag_array)
  end
end
