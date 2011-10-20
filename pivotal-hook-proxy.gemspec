# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pivotal-hook-proxy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Christoph Olszowka"]
  gem.email         = ["colszowka at capita.de"]
  gem.description   = %q{A proxy rack app that acts as an Activity Web Hook endpoint to Pivotal Tracker and forwards activity to any number of other endpoints, allowing you to have multiple Tracker Activity Web Hooks for any project}
  gem.summary       = %q{A proxy rack app that acts as an Activity Web Hook endpoint to Pivotal Tracker and forwards activity to any number of other endpoints, allowing you to have multiple Tracker Activity Web Hooks for any project}
  gem.homepage      = "https://github.com/capita/pivotal-hook-proxy"

  gem.add_dependency 'rack', '~> 1.3.5'
  gem.add_dependency 'httparty', '~> 0.8.1'

  gem.add_development_dependency 'minitest', '~> 2.6.2'
  gem.add_development_dependency 'rack-test', '~> 0.6.1'
  gem.add_development_dependency 'rr', '~> 1.0.4'
  gem.add_development_dependency 'artifice', '~> 0.6'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "pivotal-hook-proxy"
  gem.require_paths = ["lib"]
  gem.version       = PivotalHookProxy::VERSION
end
