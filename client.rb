require 'rubygems'
require 'pry'
require 'json'
require 'faraday'
require_relative 'hmac_utils'
require 'cgi'

class String

  def to_query(key)
    "#{CGI.escape(key.to_s)}=#{CGI.escape(self.to_s)}"
  end

end

class Hash

  def permit(*args)
    self.select do |k, v|
      args.include?(k)
    end
  end

  def to_param(namespace = nil)
    collect do |key, value|
      value.to_query(namespace ? "#{namespace}[#{key}]" : key)
    end.sort * '&'
  end
end

module DoughUnifiedCredential
  class Client
    attr_reader :client

    def initialize(options = {})
      build_client(options)
    end

    def build_client(options)
      @client = Faraday.new(:url => "http://localhost:#{options[:port]}") do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    def perform_request(method, path, params, body)
      puts "--> #{method.upcase} #{path} #{params} #{body}"

      @client.run_request \
        method.downcase.to_sym,
        path,
        ( body ? MultiJson.dump(body): nil ),
        {'Content-Type' => 'application/json'}
    end

    def create_user(user = {})
      request_signature = sign_request(user)

      valid_user = { user: user.permit(:email, :name, :nickname, :password, :password_confirmation, :current_password) }
      request_body = valid_user.merge(signature: request_signature,
                                      timestamp: Time.now,
                                      client_name: trusted_domain[:domain_name]).to_json
      binding.pry
      response = @client.post '/users' do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = request_body
      end

    end

    def trusted_domain
      { api_token: "G3UrfZGRiWGDd4xHt7ZLdJNkEYSt2EKYjSrDxW0XGjy5OFFTdBAM6xYjpFpV2FNaxTPpmoIBdNMxJMXWnReDOg",
        shared_secret: "83F_H1XcW6nIW-UDvEbaTUPWp5q42IazNHpKZ67exoA",
        domain_name: "example_domain",
      }
    end

    def sign_request(params)
      sha256 = OpenSSL::Digest.new("sha256")
      OpenSSL::HMAC.hexdigest(sha256, trusted_domain[:api_token], params.to_param)
    end

  end
end


client = DoughUnifiedCredential::Client.new(port: 3000)

new_user = {:email => "dain@email.com",
            :name => "dain",
            :nickname => "dain",
            :password => "password",
            :password_confirmation => "password",
           }


client.create_user(new_user)
binding.pry
### -- Must sign request ----------------------------------- ###


### -- Routes ---------------------------------------------- ###
#
# GET        /auth/:provider/initiate(.:format)  o_auth#initiate
# GET        /auth/:provider/callback(.:format)  o_auth#create
# GET        /users/sign_in(.:format)            sessions#new
# POST       /users/sign_in(.:format)            sessions#create
# DELETE     /users/sign_out(.:format)           sessions#destroy
# POST       /users/password(.:format)           passwords#create
# GET        /users/password/new(.:format)       passwords#new
# GET        /users/password/edit(.:format)      passwords#edit
# PATCH      /users/password(.:format)           passwords#update
# PUT        /users/password(.:format)           passwords#update
# GET        /users/cancel(.:format)             registrations#cancel
# POST       /users(.:format)                    registrations#create
# GET        /users/sign_up(.:format)            registrations#new
# GET        /users/edit(.:format)               registrations#edit
# PATCH      /users(.:format)                    registrations#update
# PUT        /users(.:format)                    registrations#update
# DELETE     /users(.:format)                    registrations#destroy
#