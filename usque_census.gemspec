# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'UsqueCensus/version'

Gem::Specification.new do |spec|
  spec.name        = 'UsqueCensus'
  spec.version     = UsqueCensus::VERSION
  spec.date        = '2015-08-19'
  spec.summary     = "Hola!"
  spec.description = "Connects to census api, S3, & redshift"
  spec.authors     = ["Alex Rumbaugh"]
  spec.email       = 'arumbaugh@raybeam.com'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end