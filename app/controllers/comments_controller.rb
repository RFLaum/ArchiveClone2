class CommentsController < ApplicationController
  before_action :set_story
  skip_before_action :set_story, only: %i[index_all]
  before_action :load_comment
  skip_before_action :load_comment, only: %i[new create index index_all]
  before_action :check_user, only: %i[edit update destroy]

  def create
    # @comment = @story.comments.build(comment_params)
    unless logged_in?
      anon_cant(story_path(@story) + '#comments') && return
    end
    @comment = @story.comments.build(comment_params)
    # @comment.author = current_user_name
    @comment.user = current_user
    if @comment.save
      redirect_to [@story, @comment], notice: 'Comment created.'
    else
      render 'errors/generic_error', locals: {message: 'Could not create comment.'}
    end
  end

  def show
    redirect_to (story_path(@story) + "#comment_#{params[:id]}")
  end

  def index
    redirect_to (story_path(@story) + "#comments")
  end

  #temporary
  def index_all
    @page_title = "All Comments"
    @comments = Comment.all
  end

  def edit
    # unless logged_in?
    #   anon_cant(story_path(@story) + '#comments') && return
    # end
    # check_user(@comment.user)
  end

  def update
    # return unless check_user(@comment.user)
    if @comment.update(comment_params)
      redirect_to [@story, @comment], notice: 'Comment updated.'
    else
      render :edit
    end
  end

  def destroy
    # return unless check_user(@comment.user, true)
    @comment.destroy
    redirect_to @story, notice: 'Comment deleted.'
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end

  def set_story
    @story = Story.find(params[:story_id])
    @parent = @story
  end

  def load_comment
    @comment = Comment.find(params[:id])
  end

  def check_user
    super(@comment.user, true)
  end
end
