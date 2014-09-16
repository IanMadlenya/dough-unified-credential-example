require_relative 'client'
# Note: If you get a Faraday::ConnectionRefused ~> start DUC server or point in correct location

## == Set port of DUC server (only setup for local)=============== ##

client = DoughUnifiedCredential::Client.new(port: 3000)

## == View Routes ================================================ ##

client.routes

## == Routes also function as methods with an optional argument == ##

client.new_session

## == Create user ================================================ ##

new_user = {
            :email => "dain@email.com",
            :name => "dain",
            :nickname => "dain",
            :password => "password",
            :password_confirmation => "password"
           }

response = client.create_registration(new_user)

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
response = client.create_session(new_user)

# -- response types ---------------------------- ##
# response.status
# response.body
# 404
# 201 - Success - resource as json object

## == Delete session ============================================= ##