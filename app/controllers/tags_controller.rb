class TagsController < ApplicationController
  # before_action :find_tags, only: [:find]
  before_action :set_tag #, only: %i[show edit update destroy]
  skip_before_action :set_tag, only: %i[index new create search search_results]

  # GET /tags
  # GET /tags.json
  def index
    @page_title = "Most Common Tags"
    # if can_see_adult?
    #   @tags = Tag.all
    # else
    #   @tags = Tag.where(adult: false)
    # end
    # @stories = Story.all
    # @stories = Story.non_adult(stories) unless can_see_adult?
    # @tags = Tag.most_common(stories, 100).reorder('name ASC')
    # @tags = cloud_sizer(Tag, stories, Tag.cloud_names)
    tag_set = can_see_adult? ? Tag.all : Tag.where(adult: false)
    @tags = Tag.get_top(tag_set)
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
    @page_title = @tag.name
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  def edit
    @page_title = "Editing #{@tag.name}"
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: 'Tag was successfully created.' }
        format.json { render :show, status: :created, location: @tag }
      else
        format.html { render :new }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    pars = params.permit(:adult, :implications, :delete)
    if pars[:delete].present?
      destroy && return
    end
    @tag.adult = pars[:adult].present?
    # @tag.set_adult(pars[:adult].present?)
    if pars[:implications].present?
      failed_imps = @tag.add_imps_by_name(pars[:implications])
    end
    @tag.save
    notice = ''
    if failed_imps.present?
      notice = 'Error: could not add implications for the following tag(s): '
      notice += failed_imps.join(', ')
    end
    redirect_to @tag, notice: notice
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to tags_url, notice: 'Tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search; end

  def search_results
    @results = Tag.search(params[:q]).records
  end

  def add_fave
    faves = current_user_or_guest.tags
    unless faves.include? @tag
      faves << @tag
    end
    redirect_to session[:return_page]
  end

  def remove_fave
    faves = current_user_or_guest.tags
    if faves.include? @tag
      faves.delete(@tag)
    end
    redirect_to session[:return_page]
  end

  private

  def set_tag
    # @tag = Tag.find_by(name: params[:id])
    @tag = Tag.find_by_name(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :adult)
  end

  # todo: validate search query, make this safer
  # def finder(search_string, tbl, field)
  #   input_query = search_string.downcase.squeeze(' ').strip
  #   chunks = input_query.scan(/"[^"]+"|\-|\||\w+/)
  #   query_arr = ['']
  #   until chunks.empty?
  #     holder = chunks.shift
  #     unless query_arr[0].empty?
  #       query_arr[0] += holder == '|' ? ' or ' : ' and '
  #     end
  #     query_arr[0] += field
  #     query_arr[0] += holder == '-' ? ' not like ?' : ' like ?'
  #     holder = chunks.shift if '-|'.include?(holder)
  #     query_arr << '%' + holder.delete('"').tr('*', '%') + '%'
  #   end
  #   tbl.where(query_arr)
  # end
  #
  # def find_tags
  #   @results = finder(params[:q], Tag, 'name')
  # end
end
