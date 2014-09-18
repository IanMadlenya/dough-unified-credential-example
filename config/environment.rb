require 'rubygems'
require 'pry'
require 'json'
require 'faraday'
require 'rspec'
require 'faker'
require 'nokogiri'

ROUTES = YAML::load_file("config/routes.yml")
Dir['lib/*.rb'].each { |file| load file }

YAML::load_file("config/secret.yml").each do |key, value|
  ENV[key.to_s] = value
end