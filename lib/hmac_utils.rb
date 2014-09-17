class HmacUtils
  class << self
    # Sign a set of params to be passed to the Unified Credentials server using the api token from config/secret.yml
    def sign_message(params)
      sha256 = OpenSSL::Digest.new("sha256")
      OpenSSL::HMAC.hexdigest(sha256, ENV["API_TOKEN"], to_param_format(params))
    end

    def to_param_format(params, namespace=nil)
      params.permit(:user, :client_name)
      params.collect do |key, value|
        if value.is_a? Hash
          namespace ? to_param_format(value, "#{namespace}[#{key}]") : to_param_format(value, key)
        else
          namespace ? "#{namespace}[#{key}]=#{value}" : "#{key}=#{value}"
        end
      end.sort * "&"
    end
  end
end