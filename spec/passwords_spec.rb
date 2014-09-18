require_relative 'spec_helper'

# Note: Make sure DUC server is running locally on specified port
describe "DUCS Passwords" do
  include ReturningUser
  subject { DoughUnifiedCredential::Client.new(port: 3001, logger: false) }
  let(:user) { { email: "[placeholder]", password: "password", password_confirmation: "password", nickname: "faker"} }

  before(:each) do
    create_returning(subject, user)
  end

  describe "#create" do
    context "success" do
      it "responds with 201" do
        params = { email: @returning_user }

        response = subject.create_password(params)

        expect( response.status ).to eq(201)
      end
    end

    context "failure" do
      it "responds with 400 and an error message" do
        params = { email: "bad_email@email.com" }

        response = subject.create_password(params)
        response_body = JSON.parse(response.body)

        expect( response.status ).to eq(400)
        expect( response_body["errors"].first ).to eq("Email not found")
      end
    end
  end

  describe "#edit" do
    it "updates a password with password_reset_token" do
      params = { reset_password_token: "abc123" }

      response = subject.edit_password(params)
      response_html = Nokogiri::HTML(response.body).text.gsub("\n", "")

      expect( response.status ).to eq(200)
      expect( response_html ).to include("Forgot your password? Let's reset it") # this is html
    end

    it "redirects without a password_reset_token" do
      params = { reset_password_token: "" }

      response = subject.edit_password(params)

      expect( response.status ).to eq(302)
    end
  end

  describe "#udpate" do
    it "not sure how to implement this given we have no control on getting a valid reset password token"
  end
end
