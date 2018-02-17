# -*- encoding: utf-8 -*-
require File.expand_path('../lib/edge/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jack Christensen"]
  gem.email         = ["jack@jackchristensen.com"]
  gem.description   = %q{Graph functionality for ActiveRecord}
  gem.summary       = %q{Graph functionality for ActiveRecord. Provides tree/forest modeling structure that can load entire trees in a single query.}
  gem.homepage      = "https://github.com/JackC/edge"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "edge"
  gem.require_paths = ["lib"]
  gem.version       = Edge::VERSION

  gem.add_dependency 'activerecord', ">= 4.2.10"

  gem.add_development_dependency 'pg', "~> 0.21"
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', "~> 3.6.0"
end
