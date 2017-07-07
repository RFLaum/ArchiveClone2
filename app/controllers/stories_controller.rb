class StoriesController < ApplicationController
  before_action :set_story #, only: [:show, :edit, :update, :destroy,
                          #         :new_chapter, :edit_chapter, :showall,
                          #         :create_chapter]
  skip_before_action :set_story, only: %i[index new create]

  # GET /stories
  # GET /stories.json
  def index
    # logger.debug "got to index"
    @stories = Story.all
  end

  # GET /stories/1
  # GET /stories/1.json
  def show_chapter
    chap_num = params[:chapter_num]
    render :show, locals: { chapters: [@story.get_chapter(chap_num)] }
  end

  def show
    redirect_to(url_for(@story) + '/chapters/1')
  end

  def showall
    # chapters = Chapter.where(story_id: @story.id).order("number")
    # render :show, chapters: chapters
    # logger.debug "got to showall"
    # chapters = @story.chap
    render :show, locals: { chapters: @story.get_chapters }
  end

  # GET /stories/new
  def new
    # logger.debug "got to controller new"
    @story = Story.new
  end

  # GET /stories/1/edit
  def edit
  end

  # POST /stories
  # POST /stories.json
  def create
    # logger.debug "entered create"
    @story = Story.new(story_params)
    # pars = story_params
    # logger.debug "begin story creation logging"
    # pars.each do |k,v|
    #   logger.debug "#{k}\t#{v}"
    # end
    # @story = Story.new(pars)
    #placeholder
    first_chapter = Chapter.new(story_id: @story.id, number: 1, title: '',
                                body: "placeholder")
    # logger.debug "made chapter object"
    respond_to do |format|
      if @story.save
        # logger.debug "saved story"
        @story.chapters << first_chapter
        # logger.debug "added chapter"
        format.html { redirect_to @story, notice: 'Story was successfully created.' }
        format.json { render :show, status: :created, location: @story }
      else
        format.html { render :new }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stories/1
  # PATCH/PUT /stories/1.json
  def update
    respond_to do |format|
      if @story.update(story_params)
        format.html { redirect_to @story, notice: 'Story was successfully updated.' }
        format.json { render :show, status: :ok, location: @story }
      else
        format.html { render :edit }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # def create_chapter
  #   # logger.debug "create log"
  #   # params.each do |k,v|
  #   #   logger.debug "#{k}\t#{v}"
  #   # end
  #   # params[:chapter].each do |k,v|
  #   #   logger.debug "#{k}\t#{v}"
  #   # end
  #   # @story.chapters << Chapter.new(params[:chapter])
  #   chapter_attributes = { story_id: @story.id }
  #   params[:chapter].each do |k, v|
  #     chapter_attributes[k.to_sym] = v
  #   end
  #   @story.chapters << Chapter.new(chapter_attributes)
  # end

  # def new_chapter
  #   # logger.debug "got to new chapter"
  #   chapter = Chapter.new(story: @story, number: @story.num_chapters + 1)
  #   # logger.debug "Controller log: #{chapter.class}"
  #   render :new_chapter, locals: { chapter: chapter }
  # end

  # def edit_chapter
  #   chapter = Chapter.find_by(story: @story, number: params[:chapter_num])
  #   render :edit_chapter, locals: { chapter: chapter }
  # end

  # DELETE /stories/1
  # DELETE /stories/1.json
  def destroy
    @story.destroy
    respond_to do |format|
      format.html { redirect_to stories_url, notice: 'Story was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # todo: do we always need tags?
    def set_story
      # logger.debug "got to set story"
      @story = Story.find(params[:id])
      # @tags = Tag.where(story_id: @story.id).pluck(:tag)
      @tags = @story.tags
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def story_params
      params.require(:story).permit(:title, :author)
    end

    # def chapter_params
    #   params.require(:story_id, :number).permit(:title, :body)
    # end
end
