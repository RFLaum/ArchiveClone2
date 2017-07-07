class ChaptersController < ApplicationController
  before_action :set_story
  before_action :get_row
  skip_before_action :get_row, only: %i[new create]

  #get 'stories/:story_id/add'
  def new
    id = params[:story_id]
    number = @story.num_chapters + 1
    @chapter = Chapter.new(story_id: id, number: number)
  end

  #post 'stories/:story_id'
  def create
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

  private

  def set_story
    @story = Story.find(params[:story_id])
  end

  def get_row
    @chapter = Chapter.find(story_id: params[:id], number: params[:chapter_num])
  end

  def chapter_params
    params.require(:chapter).permit(:title, :body, :number, :chapter_title)
  end
end
