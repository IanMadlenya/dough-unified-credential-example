require_relative 'spec_helper'

# Note: Make sure DUC server is running locally on specified port
describe DoughUnifiedCredential::Client do
  subject { DoughUnifiedCredential::Client.new(port: 3000, logger: false) }

  context "class setup" do
    it "instantiates a faraday client" do
      expect(subject.client).to be_a(Faraday::Connection)
    end

    it "instantiates an array of routes" do
      expect(subject.routes).to be_an(Array)
      expect(subject.routes).to_not be_empty
    end

    it "routes should be defined as methods" do
      expect(subject.routes.all? do |route|
        subject.respond_to?(route.to_sym)
      end).to be_truthy
    end
  end

  describe "#perform" do
    it "performs an http request" do
      response = subject.perform(:get, 'http://www.google.com')
      expect(response.status).to eq(200)
    end
  end

  context "routes" do
    let(:user) { { email: "[placeholder]", password: "password", password_confirmation: "password", nickname: "faker"} }

    def create_returning(user)
      @returning_user = "returning_user@email.com"
      user[:email] = @returning_user
      subject.create_registration(user)
    end

    describe "registrations" do
      describe "#create" do
        it "creates a new user when successful" do
          user[:email] = Faker::Internet.email
          response = subject.create_registration(user)
          response_body = JSON.parse(response.body)

          expect( response.status ).to eq(201)
          expect( response_body["user"]["user_id"] ).to be_truthy
        end

        it "returns a 400 status and message when a user already exists" do
          create_returning(user)
          response = subject.create_registration(user)

          response_body = JSON.parse(response.body)
          expect( response.status ).to eq(400)
          expect( response_body["errors"].first ).to eq("Email has already been taken")
        end
      end

      describe "#update" do
        it "does something sweet"
      end
    end

    context "sessions" do
      before(:each) do
        create_returning(user)
      end

      describe "#create" do
        it "creates a session for a returning user" do
          response = subject.create_session({email: @returning_user, password: "password"})

          response_body = JSON.parse(response.body)
          expect( response.status ).to eq(201)
          expect( response_body["user"]["remember_token"] ).to be_truthy
          expect( response_body["session"]["token"] ).to be_truthy
        end

        it "uses a remember_token to issue a new session" do
          new_session_response = subject.create_session({email: @returning_user, password: "password"})
          remember_token = JSON.parse(new_session_response.body)["user"]["remember_token"]

          response = subject.create_session({remember_token: remember_token})

          response_body = JSON.parse(response.body)
          expect( response.status ).to eq(201)
          expect( response_body["user"]["remember_token"] ).to be_truthy
          expect( response_body["session"]["token"] ).to be_truthy
        end

        it "returns a 401 when passed invalid credentials" do
          response = subject.create_session({email: "bad_email@email.com", password: "password"})

          response_body = JSON.parse(response.body)
          expect( response.status ).to eq(401)
          expect( response_body["errors"].first ).to eq("Invalid credentials provided.")
        end
      end

      describe "#destroy" do
        it "destroys a session for a user" do
          new_session_response = subject.create_session({email: @returning_user, password: "password"})

          session_token = JSON.parse(new_session_response.body)["session"]["token"]

          response = subject.delete_session(token: session_token)
          # TODO: ASK JVK
          # we are not storing session data on our end in this example application so devise's call to
          # :verify_signed_out_user thinks there are no active sessions and calls :respond_to_on_destroy
          # which redirects to after_sign_out_path_for
          expect(response.body).to be_empty
          expect(response.status).to eq(204)
        end
      end
    end

    context "passwords" do
      describe "#create" do
        it "does some sweet stuff"
      end

      describe "#edit" do
        it "does some sweet stuff"
      end

      describe "#udpate" do
        it "does some sweet stuff"
      end
    end
  end
end
