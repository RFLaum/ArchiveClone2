class CharactersController < ApplicationController
  before_action :set_character
  skip_before_action :set_character, only: %i[index new create]

  def index
    @page_title = "Characters"
    @characters = Character.all.paginate(page: params[:page])
  end

  def new
    @page_title = "New Character"
    @character = Character.new
  end

  def create
    @character = Character.new(char_params)
    @character.save
    redirect_to @character
  end

  def show
    @page_title = @character.name
  end

  def edit
    @page_title = "Editing #{@character.name}"
  end

  def update
    @character.update(char_params)
    redirect_to @character
  end

  def destroy
    @character.destroy
    redirect_to characters_url
  end

  private

  def set_character
    @character = Character.find(params[:id])
  end

  def char_params
    params.require(:character).permit(:name, :source_name)
  end
end
