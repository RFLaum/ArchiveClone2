module StoriesHelper
  # def story_link(story)
  #   link_to story.title, story
  # end
  def story_all(story)
    story_path(story) + '/all'
  end
end
