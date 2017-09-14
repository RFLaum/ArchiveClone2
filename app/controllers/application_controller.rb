class ApplicationController < ActionController::Base
  helper :all
  helper_method :logged_in?
  helper_method :current_user
  helper_method :current_user_or_guest
  helper_method :chapters_path
  helper_method :is_admin?
  helper_method :is_correct_user?
  helper_method :can_see_adult?
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

  # def chapters_path(chapter)
  #   story_chapters_path(chapter.story)
  # end

  def redirect_override(path)
    other_dest = session[:left_off]
    session.delete(:left_off)
    if other_dest
      redirect_to other_dest
    else
      redirect_to path
    end
  end

  def resumable_error(attempted_action, error_page)
    session[:left_off] = attempted_action
    render 'errors/' + error_page, status: :forbidden
  end

  #call when a non-logged-in user tries to do something only a logged-in user
  #can do
  def anon_cant(attempted_action)
    # session[:left_off] = attempted_action
    # render 'errors/not_logged_in', status: :forbidden
    resumable_error(attempted_action, 'not_logged_in')
  end

  def non_admin_cant(attempted_action)
    resumable_error(attempted_action, 'not_admin')
  end

  def wrong_user(correct_user, admin_can = false)
    @target_user = correct_user
    @admin_can = admin_can
    render 'errors/wrong_user', status: :forbidden
    # redirect_to
  end

  def logged_in?
    # User.exists?(session[:user])
    User.valid_user?(session[:user])
    # UsersHelper::logged_in?
  end

  def is_admin?
    logged_in? && User.find(session[:user]).admin
  end

  def can_see_adult?
    logged_in? && User.find(session[:user]).adult
  end

  def is_correct_user?(target_user, admin_can_do = false)
    return false unless logged_in?
    return true if session[:user] == target_user.name
    admin_can_do && is_admin?
  end

  def current_user
    return nil unless logged_in?
    User.find(session[:user])
  end

  def current_user_name
    logged_in? ? session[:user] : nil
  end

  def current_user_or_guest
    # answer = current_user
    # unless answer
    #   answer = User.new(name: 'guest', adult: false)
    # end
    # answer

    current_user || User.new(name: 'guest', adult: false)
  end

  def current_user_or_guest_name
    logged_in? ? session[:user] : 'guest'
  end

  #filter to keep non-admins from doing things they're not supposed to.
  #call this with before_action
  def check_admin
    non_admin_cant(request.fullpath) unless is_admin?
  end

  def check_user(target_user, admin_can = false)
    unless is_correct_user?(target_user, admin_can)
      wrong_user(target_user, admin_can)
    end
  end

  def check_logged_in
    anon_cant(request.fullpath) unless logged_in?
  end

end
