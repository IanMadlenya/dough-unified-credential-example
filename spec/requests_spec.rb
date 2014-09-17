require_relative 'spec_helper'

describe DoughUnifiedCredential::Client do

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
    describe "#create_registration" do
      it "creates a new user" do
      end

      it "returns a [401] when a user already exists" do
      end
    end

    describe "#create_registration" do
      it "creates a new user" do
      end

      it "returns a [401] when a user already exists" do
      end
    end
  end
end
