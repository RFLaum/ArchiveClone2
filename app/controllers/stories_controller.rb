class StoriesController < ApplicationController
  before_action :set_story
  skip_before_action :set_story, only: %i[index new create search search_results]
  before_action :check_logged_in, only: %i[new create]
  before_action :check_user, only: %i[edit update]
  before_action :check_user_or_admin, only: %i[destroy]

  # GET /stories
  # GET /stories.json
  def index
    @page_title = 'Stories'
    if params[:tag_id]
      @obj = Tag.find_by_name(params[:tag_id])
    elsif params[:character_id]
      @obj = Character.find(params[:character_id])
    elsif params[:source_id]
      @obj = Source.find(params[:source_id])
    else
      @stories = Story.all
    end
    if @obj.present?
      @stories = @obj.stories
      @page_title.prepend(@obj.name + ' ')
    end
    unless can_see_adult?
      @stories = @stories.reject(&:is_adult?)
    end
    @stories = @stories.paginate(page: (params[:page] || 1))
  end

  # GET /stories/1
  # GET /stories/1.json
  def show
    redirect_to @story.first_chapter
  end

  # GET /stories/1/chapters/all
  # GET /stories/1/all
  def showall
    session[:adult] = true if params[:adult]
    if @story.is_adult? && !can_see_adult?
      @page_title = 'Warning'
      render 'users/adulttemp'
    else
      @page_title = @story.title
      render :show, locals: { chapters: @story.get_chapters }
    end
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
    if @story.valid?
      current_user.stories << @story
      redirect_to @story
    else
      # @errors = @story.errors.messages
      render :new
    end
  end

  # PATCH/PUT /stories/1
  # PATCH/PUT /stories/1.json
  def update
    logger.debug "update test #{params}"
    #we do this here rather than in the model because we don't want timestamps
    #to update when tag implications are changed
    old_holder = {}
    assocs = %w[tag character source]
    # old_tags = @story.tag_ids.sort
    assocs.each do |assoc|
      old_holder[assoc] = @story.send((assoc + '_ids').to_sym).sort
    end

    # pars = params.permit(:title, :author, :tags_add, :srcs_add, :tags_public,
    #                      :sources_public, :chars_public, :chapter_title, :body,
    #                      :summary, deleted_tags: [], deleted_characters: [],
    #                      deleted_sources: [])
    pars = story_params
    if @story.update(pars)
      assocs.each do |assoc|
        #need to do this to force Rails to refresh from the DB
        @story.send((assoc + 's').to_sym).reload
        new_holder = @story.send((assoc + '_ids').to_sym).sort
        @story.touch unless old_holder[assoc] == new_holder
      end
      redirect_to @story, notice: 'Story was successfully updated.'
    else
      render :edit
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
    @page_title = "Search Results"
    @pars = search_params
    if !(@pars[:show_adult] || @pars[:show_non_adult])
      @error = "You have chosen to show neither adult nor non-adult stories."
    else
      @results = Story.search(@pars) #.records
      @results = @results.paginate(page: (params[:page] || 1))
    end
  end

  def navigate
    @chapters = @story.get_chapters
  end

  #only called for json
  # def tag_list
  #   render json: @story.tags.select('name').map(&:attributes)
  # end

  private

  # todo: do we always need tags?
  def set_story
    @story = Story.find(params[:id])
    @tags = @story.tags
  end

  def story_params
    params.require(:story)
          .permit(:title, :author, :tags_add, :srcs_add, :chars_add,
                  :tags_public, :sources_public, :chars_public, :chapter_title,
                  :body, :summary, deleted_tags: [], deleted_characters: [],
                  deleted_sources: [])
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
