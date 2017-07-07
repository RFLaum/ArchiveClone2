class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def chapter_path(chapter)
    "/stories/#{chapter.story_id}/chapters/#{chapter.number}"
  end

  def chapter_url(chapter)
    "#{request.protocol}#{request.host_with_port}#{chapter_path(chapter)}"
  end
  
end
