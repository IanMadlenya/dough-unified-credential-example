class SessionsController < ApplicationController
  def new
    flash.notice = warden.message if warden.message.present?
  end

  def create
    user = warden.authenticate!
    if user
      redirect_to authenticated_index_path, notice: "Logged in!"
    else
      render :new
    end
  end

  def destroy
    result = UnifiedCredentialsHttpHelper.delete("/users/sign_out.json", {session_token: session[:session_token]})
    if result.code == 200
      warden.logout
    end
    redirect_to new_session_path, notice: "Logged out!"
  end

end