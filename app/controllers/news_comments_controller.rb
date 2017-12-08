class NewsCommentsController < ApplicationController
  before_action :set_post
  skip_before_action :set_post, only: %i[index_all]
  before_action :load_comment
  skip_before_action :load_comment, only: %i[new create index index_all]
  before_action :check_user, only: %i[edit update destroy]

  def create
    # @comment = @story.comments.build(comment_params)
    unless logged_in?
      anon_cant(newspost_path(@post) + '#comments') && return
    end
    @comment = @post.comments.build(comment_params)
    # @comment.author = current_user_name
    @comment.user = current_user
    if @comment.save
      redirect_to [@post, @comment], notice: 'Comment created.'
    else
      render 'errors/generic_error', locals: {message: 'Could not create comment.'}
    end
  end

  def show
    redirect_to (newspost_path(@post) + "#comment_#{params[:id]}")
  end

  def index
    redirect_to (newspost_path(@post) + "#comments")
  end

  #temporary
  def index_all
    @page_title = "All Comments"
    @comments = NewsComment.all
  end

  def edit
    render 'comments/edit'
  end

  def update
    # return unless check_user(@comment.user)
    if @comment.update(comment_params)
      redirect_to [@post, @comment], notice: 'Comment updated.'
    else
      render :edit
    end
  end

  def destroy
    # return unless check_user(@comment.user, true)
    @comment.destroy
    redirect_to @post, notice: 'Comment deleted.'
  end

  private

  def comment_params
    params.require(:news_comment).permit(:content)
  end

  def set_post
    @post = Newspost.find(params[:newspost_id])
    @parent = @post
  end

  def load_comment
    @comment = NewsComment.find(params[:id])
  end

  def check_user
    super(@comment.user, true)
  end
end
