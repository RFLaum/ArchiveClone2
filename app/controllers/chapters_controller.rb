class ChaptersController < ApplicationController
  before_action :set_story
  before_action :get_row
  skip_before_action :get_row, only: %i[new create]
  # before_action :set_chapter_from_story, only: [:new, :create]

  def new
    # @chapter = Chapter.new(chapter_params)
    id = params[:story_id]
    number = @story.num_chapters + 1
    @chapter = Chapter.new(story_id: id, number: number)
  end

  def create
    # @chapter = Chapter.new(params[:chapter])
    # attributes = params[:chapter]
    # attributes[:story_id] = params[:story_id]
    # attributes[:number] = Story.find(params[:story_id]).num_
    # logger.debug "attribute listing"
    # attributes.each do |k, v|
    #   logger.debug "#{k}\t#{v}"
    #   logger.debug "#{k.class}\t#{v.class}"
    # end
    # @chapter = Chapter.new(attributes)
    # Story.find(params[:story_id]).chapters << @chapter
    # Story.find
    @chapter = @story.chapters.build(chapter_params)
    respond_to do |format|
      if @chapter.save
        format.html { redirect_to @story, notice: 'Chapter was successfully created.' }
        format.json { render :show, status: :created, location: @story }
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

  # def set_chapter_from_story
  #   id = params[:id]
  #   number = Story.find(id).num_chapters + 1
  #   @chapter = Chapter.find(id: id, number: number)
  # end

  def chapter_params
    # params.require(:story_id, :number).permit(:title, :body)
    params.require(:chapter).permit(:title, :body, :number)
  end
end
