module UsersHelper

  # def user_register_path(user)
  #   # "#{request.host_with_port}/user_confirm/#{@user.name}/auth=#{user.confirmation_hash}"
  #   # url_for(action: 'confirm', controller: 'users', only_path: false,
  #           # trailing_slash: true) + "#{@user.name}/auth=#{user.confirmation_hash}"
  #   #todo: figure out how not to hardcode in the host
  #   user_url(user.name, host: '0.0.0.0:3000') + "/auth=#{user.confirmation_hash}"
  # end

  # def logged_in?
  #   # ApplicationController.logged_in?
  #   User.exists?(session[:user])
  # end

  # def user_link(user)
  #   link_to(user.name, user)
  # end

  def time_format(twz)
    raw "<span class='time'>#{l current_user_or_guest.time_to_local(twz)}</span>"
  end
end
