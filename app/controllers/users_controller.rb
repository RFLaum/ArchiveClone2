class UsersController < ApplicationController
  include ApplicationHelper
  before_action :set_user #, only: %i[show destroy send_confirmation]
  skip_before_action :set_user, only: %i[register index create logout login]
  before_action :check_user, only: %i[deactivate]

  def register
    @user = User.new
  end

  def index
    @users = User.all
  end

  def show; end

  def create
    @user = User.new(params.require(:user).permit(:name, :email, :password,
                                                  :password_confirmation))
    if BannedAddress.is_banned?(@user.email)
      render('errors/generic_error',
             locals: { message: "That email is banned." }) && return
    end
    @user.confirmation_hash = generate_hash
    if @user.save
      send_confirmation
      # redirect_to action: index
      # render 'signup_made'
    else
      @page_title = "Sign Up"
      render 'register'
    end
  end

  def send_confirmation
    UserMailMailer.registration_confirm(@user).deliver_now
    #have to do this because sometimes this method is called from create
    render 'send_confirmation'
  end

  def confirm
    message = ""
    begin
      # @user = User.find(params[:user_name])
      # logger.debug "is_confirmed datatype: #{@user.is_confirmed.class}"
      if @user.is_confirmed
        message = "Error: user #{@user.name} already active."
      elsif @user.confirmation_hash != params[:hash]
        message = "Error: invalid confirmation hash."
      else
        message = "User account #{@user.name} activated!"
        @user.is_confirmed = true
        message = "Could not save" unless @user.save
        login_internal
      end
    rescue ActiveRecord::RecordNotFound
      message = "Error: no such user."
    end
    render :user_confirm, locals: { message: message }
  end

  def login_receiver
    # @user = User.find(params[:user_name])
    if !@user
      render :login, locals: { error_message: 'Invalid username' }
    elsif !@user.authenticate(params[:password])
      render :login, locals: { error_message: 'Invalid password' }
    elsif !@user.is_confirmed
      render "not_confirmed"
    elsif @user.deactivated
      render "deactivated"
    else
      login_internal
      redirect_override(@user)
    end
  end

  def logout
    session[:user] = nil
  end

  def destroy
    if is_correct_user?(@user)
      unregister
    elsif is_admin?
      ban
    else
      wrong_user(@user, true)
    end
  end

  def deactivate
    # if is_correct_user?(@user)
    @user.deactivated = true
    @user.save
    redirect_to action: 'index'
    # else
    #   wrong_user(@user)
    # end
  end

  private

  def ban
    @user_name = @user.name
    BannedAddress.add_email(@user.email)
    UserMailMailer.ban_notification(@user).deliver_now
    # @user.destroy
    # User.where(admin: false).find_each do |usr|
    #   if BannedAddress.is_banned?(usr.email)
    # end
    BannedAddress.destroy_users_matching(@user.email)
    render :banned
  end

  def unregister
    @user_name = @user.name
    UserMailMailer.unregistration(@user).deliver_now
    # logger.debug "Stories of user #{@user.name}: #{@user.stories.size}"
    @user.destroy
    render :unregistered
  end

  def login_internal
    session[:user] = @user.name
  end

  # def try_login(user_name, password)
  #   @user = User.find(user_name)
  #   unless user
  #     redirect_to login_page, notice: "Incorrect username"
  #   end
  #   if @user.password == password
  #     login_internal
  #     redirect_to @user
  #   else
  #     redirect_to login_page, notice: "Incorrect password"
  #   end
  # end

  def set_user
    @user = User.find(params[:id])
    @was_set_user_called = true
  end

  def check_user
    super(@user)
  end
end
