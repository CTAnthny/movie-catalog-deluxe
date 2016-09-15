ENV["RACK_ENV"] ||= "test"
require 'rspec'
require 'capybara/rspec'
require 'pry'
require_relative '../server.rb'

Capybara.app = Sinatra::Application

RSpec.configure do |config|
  config.before(:each) do
    database = Sinatra::Application.db_config[:dbname]
    system("dropdb #{database}")
    system("createdb #{database}")
    system("psql #{database} < schema.sql")
  end
end
