module DoughUnifiedCredential
  class Client
    attr_reader :client

    def initialize(options = {})
      build_client(options)
    end

    def routes
      routes = []
      ROUTES.each do |controller, actions|
        actions.each do |action, detail|
          routes << "#{action}_#{controller.gsub(/(s*)$/, '')}"
        end
      end
      routes
    end

    ROUTES.each do |controller, actions|
      actions.each do |action, detail|
        define_method "#{action}_#{controller.gsub(/(s*)$/, '')}" do |*args|
          perform(detail["method"].downcase.to_sym, ensure_json(detail["path"]), build_request_format(args.first || {}))
        end
      end
    end

    def perform(method, route, payload = {})
      @client.send(method, route, payload)
    end

    private

    def ensure_json(path)
      # This shouldn't be necessary, but when you change response type to json for faraday,
      # it creates a node named after the controller that I can't seem to manipulate / get rid of
      if path.include?(".json") then path else path.concat(".json") end
    end

    def build_request_format(payload = {})
      # 1. make sure add a user or session node before parameters
      params =  if payload.empty?
                  {}
                elsif payload[:token]
                  { session: payload.permit(:token) }
                else
                  { user: valid_user_params(payload) }
                end
      # 2. add client domain and hashify signature
      signatured_params = params.merge(client_name: ENV["DOMAIN_NAME"])
      request_signature = HmacUtils.sign_message(signatured_params)
      # 3. add timestamp and signature to params
      signatured_params.merge(signature: request_signature,
                              timestamp: Time.now)
    end

    def valid_user_params(payload)
      payload.permit(:email, :name, :nickname, :password, :password_confirmation, :current_password, :remember_token)
    end

    def build_client(options)
      @client = Faraday.new(:url => "http://localhost:#{options[:port]}") do |faraday|
        faraday.request  :url_encoded
        if options[:logger]
          faraday.response :logger
        end
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
  end
end