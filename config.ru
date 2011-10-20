require 'bundler/setup'
require 'pivotal-hook-proxy'

forward 'my_proj', 'http://www.foo.com'

run PivotalHookProxy