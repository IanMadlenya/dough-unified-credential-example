require_relative 'spec_helper'

# Note: Make sure DUC server is running locally on specified port
describe "DUCS Registrations" do
  include ReturningUser
  subject { DoughUnifiedCredential::Client.new(port: 3001, logger: false) }
  let(:user) { { email: "[placeholder]", password: "password", password_confirmation: "password", nickname: "faker"} }

  describe "#create" do
    it "creates a new user when successful" do
      user[:email] = Faker::Internet.email

      response = subject.create_registration(user)
      response_body = JSON.parse(response.body)

      expect( response.status ).to eq(201)
      expect( response_body["user"]["user_id"] ).to be_truthy
    end

    it "returns a 400 status and message when a user already exists" do
      create_returning(subject, user)

      response = subject.create_registration(user)
      response_body = JSON.parse(response.body)

      expect( response.status ).to eq(400)
      expect( response_body["errors"].first ).to eq("Email has already been taken")
    end
  end

  describe "#update" do
    before(:each) do
      create_returning(subject, user)
      @new_nickname = "my updated nickname"
    end

    it "updates a user attribute and returns a 200" do
      params = {email: @returning_user, current_password: "password", nickname: @new_nickname}

      response = subject.update_registration(params)
      response_body = JSON.parse(response.body)

      expect( response.status ).to eq(200)
      expect( response_body["nickname"] ).to eq(@new_nickname)
    end

    it "returns a 401 and an error message when it can't find a user by their email" do
      params = { email: "joe_shmoe@bomb.com", current_password: "password" }

      response = subject.update_registration(params)
      response_body = JSON.parse(response.body)

      expect( response.status ).to eq(401)
      expect( response_body["errors"] ).to include("invalid credentials")
    end

    it "returns a 400 and an error message when it can't update the user" do
      ## devise's udpate_resource method call relies on current_password being correct
      params = {email: @returning_user, password: "password", current_password: "wrong password", nickname: @new_nickname}

      response = subject.update_registration(params)
      response_body = JSON.parse(response.body)

      expect( response.status ).to eq(400)
      expect( response_body["errors"].first ).to include("password is invalid")
    end
  end
end
