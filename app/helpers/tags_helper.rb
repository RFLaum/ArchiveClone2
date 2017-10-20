module TagsHelper
  # def tags_links(tag_arr, stories)
  #   raw (tag_arr.map do |tag|
  #     link_to(tag.name, stories ? tag_stories_path(tag) : tag)
  #   end.join(', '))
  # end
  def tags_links(tag_arr, stories)
    tagesque_links(tag_arr, 'tag', stories)
  end
end
