module StoriesHelper
  # def story_link(story)
  #   link_to story.title, story
  # end
  def story_all(story)
    story_path(story) + '/all'
  end

  def tagesque_links(obj_arr, type_name, stories)
    # unless obj_arr.empty?
    #   sp_method =
    # end
    sp_method = "#{type_name}_stories_path"
    raw (obj_arr.map do |obj|
      link_to(obj.name, stories ? send(sp_method, obj) : obj)
    end.join(', '))
  end
end
