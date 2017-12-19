class BookmarksController < ApplicationController
  before_action :set_story
  # skip_before_action :set_story, only: %i[index edit_from_user]
  skip_before_action :set_story, only: %i[index]

  def new
    check_logged_in
    # @user = current_user
    # @story = Story.find(params[:id])
    # if @user.faves.include?(@story)
    #   @bookmark =
    # end
    # @bookmark = Bookmark.find_or_initialize_by(user_name: current_user_name,
    #                                            story_id: params[:id])
    # if @bookmark.new_record?
    #   edit_internal
    # else
    #   @page_title = "New Bookmark"
    #   render :new
    # end
    clear_saved_location
    u_name = current_user_name
    if @story.favers.exists?(name: u_name)
      @bookmark = @story.bookmarks.find_by(user_name: u_name)
      edit_internal
    else
      @bookmark = @story.bookmarks.build(user_name: u_name)
      @page_title = "New Bookmark"
      render :new
    end
  end

  def edit
    if params[:story_id].present?
      clear_saved_location
      # set_story
      @bookmark = @story.bookmarks.find_by(user_name: current_user_name)
    else
      @bookmark = Bookmark.find(params[:id])
      save_location(user_bookmarks_path(@bookmark.user))
      # @story = @bookmark.story
    end
    edit_internal
  end

  # def edit_from_user
  #   # user = current_user
  #   # save_location(user_bookmarks(user))
  #   # save_location()
  #   @bookmark = Bookmark.find(params[:id])
  #   save_location(user_bookmarks(@bookmark.user))
  #   @story = @bookmark.story
  #   edit_internal
  # end

  def create
    @story.favers << current_user
    update
  end

  def update
    @story.bookmarks.find_by(user_name: current_user_name).update(param_clean)
    # redirect_to @story
    redirect_override(@story)
  end

  def index
    @show_summaries = true
    cu = current_user_or_guest
    if params[:story_id].present?
      @story = Story.find(params[:story_id])
      #TODO: test this
      @bookmarks = @story.visible_bookmarks(cu)
      # @bookmarks = @story.bookmarks.where(private: false)
      @show_summaries = false
    elsif params[:user_id].present?
      @user = User.find_by(name: params[:user_id])
      # u_name = params[:user_id]
      # @bookmarks = @user.bookmarks
      # unless is_correct_user?(@user)
      #   @bookmarks = @bookmarks.where(private: false)
      # end
      @bookmarks = @user.visible_bookmarks(cu)
    else
      #don't need to filter by privacy here because this is just for testing
      #purposes
      #TODO: remove this for production
      @bookmarks = Bookmark.all
    end
    @bookmarks = @bookmarks.paginate(page: params[:page])
  end

  private

  def param_clean
    params.require(:bookmark).permit(:user_notes, :private)
  end

  def edit_internal
    @page_title = "Editing Bookmark"
    render :edit
  end

  def set_story
    if params[:story_id].present?
      @story = Story.find(params[:story_id])
    else
      @story = Bookmark.find(params[:id]).story
    end
  end
end
