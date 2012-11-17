require 'rubygems'
require 'bundler/setup'
require 'simplecov'
require 'rspec'
require 'mocha/api'
SimpleCov.start

require_relative '../lib/phl_geocode'

RSpec.configure do |config|
  # some (optional) config here
end
