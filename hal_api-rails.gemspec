# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hal_api/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "hal_api-rails"
  spec.version       = HalApi::Rails::VERSION
  spec.authors       = ["Chris Rhoden", "Andrew Kuklewicz"]
  spec.email         = ["carhoden@gmail.com", "andrew@beginsinwonder.com"]

  spec.summary       = %q{JSON HAL APIs on Rails in the style of PRX}
  spec.description   = %q{JSON HAL APIs on Rails in the style of PRX v4. Uses ROAR}
  spec.homepage      = "https://www.github.com/PRX/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", ">= 3.0.0"
  spec.add_dependency "actionpack", ">= 3.0.0"
  spec.add_dependency "rack-test", "~> 0.6.2"
  spec.add_dependency "activesupport", ">= 3.0.0"
  spec.add_dependency "responders", "~> 2.0"
  spec.add_dependency "roar-rails", "~> 1.0.1"
  spec.add_dependency "multi_json"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
