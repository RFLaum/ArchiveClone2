class ChaptersController < ApplicationController
  before_action :set_story
  before_action :get_row
  skip_before_action :get_row, only: %i[new create]
  before_action :check_user, only: %i[new create edit update destroy multi_update]

  #get 'stories/:story_id/add'
  def new
    number = @story.num_chapters + 1
    # @chapter = Chapter.new(story_id: @story.id, number: number)
    @chapter = @story.chapters.build(number: number)
    @page_title = "New Chapter"
  end

  #post 'stories/:story_id'
  def create
    # wrong_user(@story.author) && return unless is_correct_user?(@story.author)
    # return unless check_user(@story.user)
    @chapter = @story.chapters.build(chapter_params)
    # respond_to do |format|
      if @chapter.save
        # format.html { redirect_to @story, notice: 'Chapter was successfully created.' }
        # format.json { render :show, status: :created, location: @story }
        # format.html { redirect_to @chapter , notice: 'Chapter was successfully created.' }
        # format.json { render :show, status: :created, location: @chapter }
        redirect_to @chapter
      else
        render :new
        # format.html { render :new }
        # format.json { render json: @chapter.errors, status: :unprocessable_entity }
      end
    # end
  end

  def show
    session[:adult] = true if params[:adult]
    if @story.is_adult? && !can_see_adult?
      @page_title = 'Warning'
      render 'users/adulttemp'
    else
      @page_title = @story.title
      @next_chapter = @prev_chapter = nil
      if @chapter.number > 1
        @prev_chapter = @story.get_chapter(@chapter.number - 1)
      end
      if @story.chapters.size > @chapter.number
        @next_chapter = @story.get_chapter(@chapter.number + 1)
      end
    end
  end

  def edit
    # return unless check_user(@story.user)
    # chap_title = @chapter.title.empty? ? @chapter.number : "\"#{@chapter.title}\""
    # @page_title = "Editing Chapter #{chap_title} of #{@story.title}"
    @page_title = "Editing Chapter #{@chapter.heading} of #{@story.title}"
  end

  def update
    # return unless check_user(@story.user)
    if @chapter.update(chapter_params)
      redirect_to @chapter, notice: 'Chapter was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @chapter.destroy
    redirect_to @story
  end

  def multi_update
    @page_title = "Multiple Chapter Update"
    @position = @chapter.number + 1
  end

  private

  def set_story
    @story = Story.find(params[:story_id])
  end

  def get_row
    # @chapter = Chapter.find_by([params[:story_id], params[:id]])
    # @chapter = Chapter.find(params[:id])
    s_id = params[:story_id]
    c_id = params[:id]
    if pos = c_id.rindex(',')
      c_id = c_id[(pos + 1)..-1]
    end
    # logger.debug "story_id: #{s_id}"
    # logger.debug "c_id: #{c_id}"
    # @chapter = Chapter.find([params[:story_id], params[:id]])
    begin
      @chapter = Chapter.find([s_id, c_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to story_all_path(s_id)
    end
  end

  def chapter_params
    params.require(:chapter).permit(:title, :body, :number, :chapter_title)
  end

  def check_user
    super(@story.user)
  end
end
