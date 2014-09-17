load File.expand_path('../config/environment.rb',  __FILE__)
# Note: If you get a Faraday::ConnectionRefused ~> start DUC server or point in correct location

def separator(test)
  puts "\n========= #{test} ===========\n\n"
end

def results(response)
  puts "\n--- results ---\n\n"
  puts "status: #{response.status}"
  puts "body: #{response.body}"
end
## == Set port of DUC server (only setup for local)=============== ##

client = DoughUnifiedCredential::Client.new(port: 3000, logger: true)

## == View Routes ================================================ ##

client.routes

## == Routes also function as methods with an optional argument == ##

separator("new session")
response = client.new_session
puts "\n--- results ---\n\n"
puts "status: #{response.status}"
# should be 406 - new session not set up for json requests

## == Create user ================================================ ##

new_user = {
            :email => "dain@email.com",
            :name => "dain",
            :nickname => "dain",
            :password => "password",
            :password_confirmation => "password"
           }

separator "create user"
results client.create_registration(new_user)

# -- response types ---------------------------- ##
# response.status
# response.body
# 400 - Bad Request - email already taken
# 201 - Success - resource as json object


## == Create session ============================================= ##

existing_user = {
                  email: "dain@email.com",
                  password: "password"
                }

separator("create session")
results client.create_session(existing_user)

# -- response types ---------------------------- ##
# response.status
# response.body
# 404
# 201 - Success - resource as json object


## == Update password ============================================= ##


# TODO