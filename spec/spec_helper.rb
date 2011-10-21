require 'rubygems'
require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end
require 'bundler/setup'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/mock'
require 'rack/test'
require 'rr'
require 'artifice'
require 'tracker-hook-forwarder'

# Do not show log statements while testing
TrackerHookForwarder.logger.level = Logger::FATAL