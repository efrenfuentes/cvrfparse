# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cvrfparse/version'

Gem::Specification.new do |spec|
  spec.name          = 'cvrfparse'
  spec.version       = CVRFPARSE::VERSION
  spec.authors       = ["Efrén Fuentes"]
  spec.email         = ["efrenfuentes@gmail.com"]
  spec.summary       = 'Utility for validate CVRF files '
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "https://github.com/efrenfuentes/cvrfparse"
  spec.license       = "GPLv3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_dependency 'thor', '~> 0.19'
end
