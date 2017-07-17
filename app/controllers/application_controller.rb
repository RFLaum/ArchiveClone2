class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # def default_url_options
  #   { host: "0.0.0.0:3000" }
  # end

  def chapter_path(chapter)
    "/stories/#{chapter.story_id}/chapters/#{chapter.number}"
  end

  def chapter_url(chapter)
    "#{request.protocol}#{request.host_with_port}#{chapter_path(chapter)}"
  end

  def redirect_override(path)
    other_dest = session[:left_off]
    session.delete(:left_off)
    if other_dest
      redirect_to other_dest
    else
      redirect_to path
    end
  end

  #call when a non-logged-in user tries to do something only a logged-in user
  #can do
  def anon_cant(attempted_action)
    session[:left_off] = attempted_action
    render 'errors/not_logged_in'
  end
end
