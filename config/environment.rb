require 'faker'
require 'json'
require 'faraday'
require 'nokogiri'
require 'pry'
require 'rspec'
require 'rubygems'
require 'YAML'

ROUTES = YAML::load_file("config/routes.yml")
Dir['lib/*.rb'].each { |file| load file }

YAML::load_file("config/secret.yml").each do |key, value|
  ENV[key.to_s] = value
end