Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :session_token, :unified_credentials
  manager.failure_app = lambda { |env| SessionsController.action(:new).call(env) }
end

Warden::Manager.after_set_user do |user,auth,opts|
  # Do nothing here
end

Warden::Manager.before_logout do |user,auth,opts|
  # TODO: Don't have request scope / session here, not sure how to grab session token for
end

Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.find(id)
end

Warden::Strategies.add(:session_token) do
  def valid?
    puts "SessionToken.valid? #{session.inspect}"
    session["session_token"]
  end

  def authenticate!
    puts "SessionToken#authenticate!"
    response = UnifiedCredentialsHttpHelper.post("/sessions/validate.json", { session_token: session[:session_token] })
    if response.code == 200
      user = User.find_by_unified_id response["user_id"]
      success! user
    else
      fail "Your session has expired"
    end
  end
end

Warden::Strategies.add(:unified_credentials) do
  def valid?
    params['encrypted_token'] || (params['email'] && params['password'])
  end

  ##
  # Authenticate user based on request params
  def authenticate!
    post_body = if params['encrypted_token']
      session["remember_token"] = decipher_token(params['encrypted_token'])
      { remember_token: session["remember_token"] }
    else
      { email: params['email'],
        password: params['password'] }
    end

    # #TODO - This should be an http helper (or at least named more obviously)
    response = UnifiedCredentialsHttpHelper.post("/users/sign_in.json", post_body)

    if response.success?
      user = User.find_by_unified_id response["user_id"]
      # TODO - handle upsert where user doesn't exist here yet
      if user
        session["session_token"] = response["session_token"]
        session["remember_token"] = response["remember_token"]
        success! user
      else
        fail "User doesn't exist here"
      end
    else
      fail response.first || "Incorrect credentials"
    end
  end

  private
  def decipher_token(content)
    shared_secret = ENV['UNIFIED_CREDS_PRE_SHARED']

    encryptor = ActiveSupport::MessageEncryptor.new(shared_secret)
    encryptor.decrypt_and_verify(URI.unescape(content))
  end
end