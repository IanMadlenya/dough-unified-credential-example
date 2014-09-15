class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #require_logged_in with: :has_bob_subscription, :whatever, for: domain

  # include HTTParty



  protected
  ## Signs user in or redirects
  def authenticate_user!
    if valid_session?
      return current_user
    else
      if authenticate_via_remember?
        return current_user
      else
        # Session is expired, as is remember token
        warden.logout
        warden.authenticate!
      end
    end
  end

  def current_user
    warden.user
  end
  helper_method :current_user

  def user_signed_in?
    !!current_user
  end

  def warden
    env['warden']
  end


  def valid_session?
    # Warden doesn't actually run strategies if a user is present in the session
    if session[:session_token]
      params = { session_token: session[:session_token] }
      path = "/sessions/validate.json"
      response = UnifiedCredentialsHttpHelper.post(path, params)
      if response.code == 200
        return true
      end
    end
    false
  end

  def authenticate_via_remember?
    # TODO - Warden doesn't actually run strategies if a user is present in the session
    # This can probably be a separate strategy
    params = {remember_token: session[:remember_token]}
    path = "/users/sign_in.json"
    response = UnifiedCredentialsHttpHelper.post(path, params)
    case response.code
      when 201
        session[:session_token] = response["session_token"]
        session[:user_id] = response["user_id"]
        session[:remember_token] = response["remember_token"]
      when 401
        redirect_to new_session_path
      else
    end
  end


end
