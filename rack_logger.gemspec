# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack_logger/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Allen Wei"]
  gem.email         = ["digruby@gmail.com"]
  gem.description   = %q{Rack logger support ActiveSupport LogSubscriber}
  gem.homepage      = "allenwei.cn"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rack_logger"
  gem.require_paths = ["lib"]
  gem.version       = RackLogger::VERSION


  gem.add_runtime_dependency 'rack'

  gem.add_development_dependency 'rake'
end
