class UsersController < ApplicationController
  include ApplicationHelper
  before_action :set_user, only: %i[show destroy]

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
      UserMailMailer.registration_confirm(@user).deliver_now
      # redirect_to action: index
      render 'signup_made'
    else
      @page_title = "Sign Up"
      render 'register'
    end
  end

  def confirm
    message = ""
    begin
      @user = User.find(params[:user_name])
      logger.debug "is_confirmed datatype: #{@user.is_confirmed.class}"
      if @user.is_confirmed
        message = "Error: user #{@user.name} already active."
      elsif @user.confirmation_hash != params[:hash]
        message = "Error: invalid confirmation hash."
      else
        message = "User account #{@user.name} activated!"
        @user.is_confirmed = true
        @user.save
        login_internal
      end
    rescue ActiveRecord::RecordNotFound
      message = "Error: no such user."
    end
    render :user_confirm, locals: { message: message }
  end

  def login_receiver
    @user = User.find(params[:user_name])
    if !@user
      render :login, locals: { error_message: 'Invalid username' }
    elsif @user.authenticate(params[:password])
      login_internal
      redirect_override(@user)
    else
      render :login, locals: { error_message: 'Invalid password' }
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

  private

  def ban
    @user_name = @user.name
    BannedAddress.add_email(@user.email)
    UserMailMailer.ban_notification(@user).deliver_now
    @user.destroy
    render :banned
  end

  def unregister
    @user_name = @user.name
    UserMailMailer.unregistration(@user).deliver_now
    logger.debug "Stories of user #{@user.name}: #{@user.stories.size}"
    @user.destroy
    render :unregistered
  end

  def login_internal
    session[:user] = @user.name
  end

  def try_login(user_name, password)
    @user = User.find(user_name)
    unless user
      redirect_to login_page, notice: "Incorrect username"
    end
    if @user.password == password
      login_internal
      redirect_to @user
    else
      redirect_to login_page, notice: "Incorrect password"
    end
  end

  def set_user
    @user = User.find(params[:id])
  end
end
