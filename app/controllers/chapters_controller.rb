class ChaptersController < ApplicationController
  before_action :set_story
  before_action :get_row
  skip_before_action :get_row, only: %i[new create]

  #get 'stories/:story_id/add'
  def new
    # id = params[:story_id]
    if is_correct_user?(@story.author)
      number = @story.num_chapters + 1
      @chapter = Chapter.new(story_id: @story.id, number: number)
    else
      wrong_user(@story.author)
    end
  end

  #post 'stories/:story_id'
  def create
    wrong_user(@story.author) && return unless is_correct_user?(@story.author)
    @chapter = @story.chapters.build(chapter_params)
    respond_to do |format|
      if @chapter.save
        # format.html { redirect_to @story, notice: 'Chapter was successfully created.' }
        # format.json { render :show, status: :created, location: @story }
        format.html { redirect_to @chapter, notice: 'Chapter was successfully created.' }
        format.json { render :show, status: :created, location: @chapter }
      else
        format.html { render :new }
        format.json { render json: @chapter.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    # @chapter = render 'stories/show', locals: { chapters: [@chapter] }
    @next_chapter = @prev_chapter = nil
    if @chapter.number > 1
      @prev_chapter = @story.get_chapter(@chapter.number - 1)
    end
    if @story.chapters.size > @chapter.number
      @next_chapter = @story.get_chapter(@chapter.number + 1)
    end
  end

  def edit; end

  def update
    if @chapter.update(chapter_params)
      redirect_to @chapter, notice: 'Chapter was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_story
    @story = Story.find(params[:story_id])
  end

  def get_row
    # @chapter = Chapter.find_by([params[:story_id], params[:id]])
    # @chapter = Chapter.find(params[:id])
    @chapter = Chapter.find([params[:story_id], params[:id]])
  end

  def chapter_params
    params.require(:chapter).permit(:title, :body, :number, :chapter_title)
  end
end
