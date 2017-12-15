module StoriesHelper
  #TODO: replace this with an :as in routes.rb
  def story_all(story)
    story_path(story) + '/all'
  end

  #produces a comma-separated list of links.
  #obj_arr: array of objects to link to
  #type_name: what kind of object it is (e.g. tag, character, source)
  #stories: boolean indicating whether to link to the list of stories
  #associated with the object, rather than the object itself.
  def tagesque_links(obj_arr, type_name, stories)
    sp_method = "#{type_name}_stories_path"
    raw (obj_arr.map do |obj|
      link_to(obj.name, stories ? send(sp_method, obj) : obj)
    end.join(', '))
  end
end
