require_relative "spec_helper"

describe "DUCS Sessions" do
  include ReturningUser
  subject { DoughUnifiedCredential::Client.new(port: 3001, logger: false) }
  let(:user) { { email: "[placeholder]", password: "password", password_confirmation: "password", nickname: "faker"} }

  context "sessions" do
    before(:each) do
      create_returning(subject, user)
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
end