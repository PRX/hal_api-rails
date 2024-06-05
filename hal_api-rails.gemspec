# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hal_api/rails/version'

Gem::Specification.new do |spec|
  spec.name          = 'hal_api-rails'
  spec.version       = HalApi::Rails::VERSION
  spec.authors       = ['Chris Rhoden', 'Andrew Kuklewicz']
  spec.email         = ['carhoden@gmail.com', 'andrew@beginsinwonder.com']

  spec.summary       = 'JSON HAL APIs on Rails in the style of PRX'
  spec.description   = 'JSON HAL APIs on Rails in the style of PRX. Uses ROAR'
  spec.homepage      = 'https://www.github.com/PRX/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'multi_json'
  spec.add_dependency 'roar-rails'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'standard'
  spec.add_development_dependency 'kaminari'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rails', '>= 5'
  spec.add_development_dependency 'rake',  '>= 12'
end
