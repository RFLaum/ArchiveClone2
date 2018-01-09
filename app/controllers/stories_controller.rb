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
      @base_stories = Story.all
      unless can_see_adult?
        @base_stories = Story.non_adult(@base_stories)
                             .or(stories.where(user: current_user_or_guest))
      end
    end
    if @obj.present?
      @base_stories = @obj.visible_stories(current_user_or_guest)
      # @page_title.prepend(@obj.name + ' ')
      @page_title += " in \"#{@obj.name}\""
    end

    @base_stories = do_filtering(@base_stories)
    # exact_filters = {}
    # fuzzy_filters = {}
    #
    # %i[tags sources characters].each do |tp|
    #   exact_filters[tp] = params["filter_#{tp}".to_sym]
    #   fuzzy_filters[tp] = params["other_#{tp}".to_sym]
    # end
    # @base_stories = Story.tsc_wrapper(@base_stories, exact_filters, true)
    # @base_stories = Story.tsc_wrapper(@base_stories, fuzzy_filters, false)

    # query_params = {
    #   tags: params[:other_tags],
    #   sources: params[:other_sources],
    #   characters: params[:other_characters]
    # }
    # @base_stories = Story.tsc_search(@base_stories, query_params)
    # @base_stories = Story.tsc_search(@base_stories, params)

    # sort_by = params[:sort_by] ? params[:sort_by].to_sym : :updated_at
    # sort_dir = params[:sort_direction] ? params[:sort_direction].to_sym : :desc

    # if sort_by == :num_comments
    #   @stories = @base_stories.left_outer_joins(:comments)
    #                           .select('stories.*, COUNT(comments.*)')
    #                           .group('stories.id')
    #                           .order("COUNT(comments.*) #{sort_dir}")
    # else
    #   @stories = @base_stories.order(sort_by => sort_dir)
    # end

    # unless can_see_adult?
    #   # @base_stories = @base_stories.reject(&:is_adult?)
    #   @base_stories = Story.non_adult(@base_stories)
    # end

    @stories = Story.s_sort(@base_stories, params[:sort_by], params[:sort_direction])
    @stories = @stories.paginate(page: params[:page], per_page: 10)
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
    @page_title = "New Story"
    @story = Story.new
  end

  # GET /stories/1/edit
  def edit
    @page_title = "Editing " + @story.title
  end

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
    #we do this here rather than in the model because we don't want timestamps
    #to update when tag implications are changed
    old_holder = {}
    assocs = %w[tag character source]
    # old_tags = @story.tag_ids.sort
    assocs.each do |assoc|
      old_holder[assoc] = @story.send((assoc + '_ids').to_sym).sort
    end

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
    redirect_to stories_path
    # respond_to do |format|
    #   format.html { redirect_to stories_url, notice: 'Story was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  def search
    @page_title = "Story Search"
    render 'full_search_form'
  end

  def search_results
    @page_title = "Search Results"
    @pars = search_params
    if !(@pars[:show_adult] || @pars[:show_non_adult])
      @error = "You have chosen to show neither adult nor non-adult stories."
    else
      @base_results = Story.search(@pars)
      @base_results = do_filtering(@base_results)
      @results = @base_results.paginate(page: params[:page])
    end
  end

  def navigate
    @page_title = "#{@story.title}: Chapter Index"
    @chapters = @story.get_chapters
  end

  def multi_update
    @story.split(params[:body], params[:position].to_i)
    redirect_to chap_nav_path(@story)
  end
  #only called for json
  # def tag_list
  #   render json: @story.tags.select('name').map(&:attributes)
  # end

  private

  def do_filtering(story_set)
    exact_filters = {}
    fuzzy_filters = {}

    %i[tags sources characters].each do |tp|
      exact_filters[tp] = params["filter_#{tp}".to_sym]
      fuzzy_filters[tp] = params["other_#{tp}".to_sym]
    end
    # logger.debug "do_filtering test"
    # fuzzy_filters.each do |k, v|
      # logger.debug "#{k}: #{v}"
    # end
    answer = Story.tsc_wrapper(story_set, exact_filters, true)
    Story.tsc_wrapper(answer, fuzzy_filters, false)
  end

  # todo: do we always need tags?
  def set_story
    @story = Story.find(params[:id])
    @tags = @story.tags
  end

  def story_params
    params.require(:story)
          .permit(:title, :author, :tags_add, :srcs_add, :chars_add,
                  :tags_public, :sources_public, :chars_public, :chapter_title,
                  :body, :summary, :adult_override, deleted_tags: [],
                  deleted_characters: [], deleted_sources: [])
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
                  :show_non_adult, :tags, :sources, :characters, :sort_by,
                  :sort_direction)
  end
end
