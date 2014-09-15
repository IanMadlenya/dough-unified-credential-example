class UnifiedCredentialsHttpHelper
  class << self
    # TODO - move into http helper, make service encapsulate path, request type, params
    def post(path, params)
      Rails.logger.info("UnifiedCredentialsHttpHelper#post")
      url = CasClient::Application.config.unified_credentials['host']+path
      params[:client_name] = ENV['UNIFIED_CREDS_CLIENT_ID']
      params[:signature] = HmacUtils.sign_message(params)
      HTTParty.post(url,
        body: params
      )
    end

    def get(path, params)
      url = CasClient::Application.config.unified_credentials['host']+path
      params[:client_name] = ENV['UNIFIED_CREDS_CLIENT_ID']
      params[:signature] = HmacUtils.sign_message(params)
      HTTParty.get(url,
        body: params
      )
    end

    def delete(path, params)
      Rails.logger.info("UnifiedCredentialsHttpHelper#delete")
      url = CasClient::Application.config.unified_credentials['host']+path
      params[:client_name] = ENV['UNIFIED_CREDS_CLIENT_ID']
      params[:signature] = HmacUtils.sign_message(params)
      HTTParty.delete(url,
        body: params
      )
    end
  end
end