class StoriesController < ApplicationController
  before_action :set_story
  skip_before_action :set_story, only: %i[index new create search search_results]
  before_action :check_logged_in, only: %i[new create]
  before_action :check_user, only: %i[edit update]
  before_action :check_user_or_admin, only: %i[destroy]

  # GET /stories
  # GET /stories.json
  def index
    if params[:tag_id]
      @tag = Tag.find_by_name(params[:tag_id])
      @stories = @tag.stories
    else
      @stories = Story.all
    end
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
    redirect_to @story.first_chapter
  end

  # GET /stories/1/chapters/all
  # GET /stories/1/all
  def showall
    @page_title = @story.title
    render :show, locals: { chapters: @story.get_chapters }
  end

  # GET /stories/new
  def new
    @story = Story.new
  end

  # GET /stories/1/edit
  def edit; end

  # POST /stories
  # POST /stories.json
  def create
    @story = Story.new(story_params)
    current_user.stories << @story
    redirect_to @story
  end

  # PATCH/PUT /stories/1
  # PATCH/PUT /stories/1.json
  def update
    pars = params.permit(:title, :author, :tags_add, :chapter_title, :body,
                         :summary, deleted_tags: [])
    respond_to do |format|
      if @story.update(pars)
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

  def search
    render 'full_search_form'
  end

  def search_results
    @pars = search_params
    if !(@pars[:show_adult] || @pars[:show_non_adult])
      @error = "You have chosen to show neither adult nor non-adult stories."
    end
    @results = Story.search(@pars) #.records
  end

  private

  # todo: do we always need tags?
  def set_story
    @story = Story.find(params[:id])
    @tags = @story.tags
  end

  def story_params
    params.require(:story).permit(:title, :author, :tags_public, :chapter_title,
                                  :body, :summary) #, deleted_tags: [])
  end

  alias :super_check_user :check_user

  def check_user
    super(@story.user)
  end

  def check_user_or_admin
    super_check_user(@story.user, true)
  end

  def search_params
    params.permit(:title, :author, :updated, :created, :show_adult,
                  :show_non_adult, :tags, :sort_by, :sort_direction)
  end
end
