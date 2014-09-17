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
          perform(detail["method"].downcase.to_sym, detail["path"].concat('.json'), build_request_format(args.first || {}))
        end
      end
    end

    def perform(method, route, payload = {})
      @client.send(method, route, payload)
    end

    private

    def build_request_format(payload = {})
      # 1. add user node to user parameters
      params = {user: payload.permit(:email, :name, :nickname, :password, :password_confirmation, :current_password)}
      # 2. add client domain and hashify signature
      signatured_params = params.merge(client_name: ENV["DOMAIN_NAME"])
      request_signature = HmacUtils.sign_message(signatured_params)
      # 3. add timestamp and signature to params
      signatured_params.merge(signature: request_signature,
                              timestamp: Time.now)
    end

    def build_client(options)
      @client = Faraday.new(:url => "http://localhost:#{options[:port]}") do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
  end
end