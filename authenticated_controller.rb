class AuthenticatedController < ApplicationController
  before_filter :authenticate_user!

  def index
    @session_token = session[:session_token]
    @remember_token = session[:remember_token]
  end
end
