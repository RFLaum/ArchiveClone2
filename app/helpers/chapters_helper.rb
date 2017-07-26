module ChaptersHelper
  # def chapter_path(chapter)
  #   "/stories/#{chapter.story_id}/chapters/#{chapter.number}"
  # end
  #
  # def chapter_url(chapter)
  #   "#{request.protocol}#{request.host_with_port}#{chapter_path(chapter)}"
  # end
  def chapter_path(chapter)
    story_chapters_path(chapter.story) + "/#{chapter.number}"
  end

  def chapter_url(chapter)
    story_chapters_url(chapter.story) + "/#{chapter.number}"
  end

  def edit_story_chapter_path(chapter)
    chapter_path(chapter) + '/edit'
  end
  #
  # def chapter_url(chapter)
  #   story_chapters_url(chapter.story, chapter.number)
  # end
end
