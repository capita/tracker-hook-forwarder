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
require 'pivotal-hook-proxy'

# Do not show log statements while testing
PivotalHookProxy.logger.level = Logger::FATAL