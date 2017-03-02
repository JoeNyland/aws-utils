# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws/utils/version'

Gem::Specification.new do |spec|
  spec.name          = "aws-utils"
  spec.version       = Aws::Utils::VERSION
  spec.authors       = ["Joe Nyland"]
  spec.email         = ["joenyland@me.com"]

  spec.summary       = 'AWS utilities'
  spec.description   = 'A collection of utilities for use on AWS'
  spec.homepage      = 'https://github.com/JoeNyland/aws-utils'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency 'aws-sdk', '~>2'
end
