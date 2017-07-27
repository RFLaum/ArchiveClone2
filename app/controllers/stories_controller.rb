class StoriesController < ApplicationController
  before_action :set_story
  skip_before_action :set_story, only: %i[index new create]

  # GET /stories
  # GET /stories.json
  def index
    @stories = Story.all
  end

  # GET stories/1/chapters/1
  # def show_chapter
  #   chap_num = params[:chapter_num]
  #   render :show, locals: { chapters: [@story.get_chapter(chap_num)] }
  # end

  # GET /stories/1
  # GET /stories/1.json
  def show
    #there's got to be a better way of doing this
    # redirect_to(url_for(@story) + '/chapters/1')
    redirect_to @story.first_chapter
  end

  # GET /stories/1/chapters/all
  # GET /stories/1/all
  def showall
    render :show, locals: { chapters: @story.get_chapters }
  end

  # GET /stories/new
  def new
    if
      logged_in? #session[:user]
      @story = Story.new
      render "new"
    else
      # render "errors/generic_error", locals: {
      #   message: "You must be logged in to post a story"
      # }
      anon_cant(request.fullpath)
    end
  end

  # GET /stories/1/edit
  def edit; end

  # POST /stories
  # POST /stories.json
  def create
    @story = Story.new(story_params)
    User.find(session[:user]).stories << @story
    redirect_to @story
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

  # todo: do we always need tags?
  def set_story
    @story = Story.find(params[:id])
    @tags = @story.tags
  end

  def story_params
    params.require(:story).permit(:title, :author, :tags_public,
                                  :chapter_title, :body)
  end

  # def story_params_new
  #   params.require(:story).permit(:title, :author, :chapter_title, :body)
  # end
end
