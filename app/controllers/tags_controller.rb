class TagsController < ApplicationController
  before_action :find_tags, only: [:find]
  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.all
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # GET /tags/1/edit
  def edit
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
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to @tag, notice: 'Tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { render :edit }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find_by(name: params[:name])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(:name, :adult)
    end

    def finder(search_string, tbl, field)
      input_query = search_string.downcase.squeeze(' ').strip
      chunks = input_query.scan(/"[^"]+"|\-|\||\w+/)
      query_arr = ['']
      until chunks.empty?
        holder = chunks.shift
        unless query_arr[0].empty?
          query_arr[0] += holder == '|' ? ' or ' : ' and '
        end
        query_arr[0] += field
        query_arr[0] += holder == '-' ? ' not like ?' : ' like ?'
        holder = chunks.shift if '-|'.include?(holder)
        query_arr << '%' + holder.delete('"').tr('*', '%') + '%'
      end
      tbl.where(query_arr)
    end

    def find_tags
      # logger.debug "got to find tags"
      @results = finder(params[:q], Tag, 'name')
    end
end
