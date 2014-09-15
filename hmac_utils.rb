class HmacUtils
  class << self
    ##
    # Sign a set of params to be passed to the Unified Credentials server using the api token from config/unified_auth_secret.yml
    def sign_message(params)
      sha256 = OpenSSL::Digest.new("sha256")
      OpenSSL::HMAC.hexdigest(sha256, ENV["UNIFIED_CREDS_API_TOKEN"], params.to_param)
    end

    def to_param_format(params, namespace=nil)
      params.collect do |key, value|
        if value.class == Hash
          namespace ? to_param_format(value, "#{namespace}[#{key}]") : to_param_format(value, key)
        else
          namespace ? "#{namespace}[#{key}]=#{value}" : "#{key}=#{value}"
        end
      end.sort * "&"
    end
  end
end