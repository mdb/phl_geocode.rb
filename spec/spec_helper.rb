require 'rubygems'
require 'rspec'
require 'bundler/setup'
require 'simplecov'
require 'mocha/api'
SimpleCov.start

require_relative '../lib/phl_geocode'

RSpec.configure do |config|
  # some (optional) config here
end
