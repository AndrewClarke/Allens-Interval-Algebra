# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'allens/version'

Gem::Specification.new do |spec|
  spec.name          = 'allens'
  spec.version       = Allens::VERSION
  spec.authors       = ['Andrew Clarke']
  spec.email         = ['a.andrew.clarke@gmail.com']
  spec.description   = 'Implement the operators of Allens Interval Algebra'
  spec.summary       = 'Allens Interval Algebra'
  spec.homepage      = 'http://rubygems.org/gems/allens'
  spec.license       = 'MIT'
  spec.date          = '2014-04-30'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end

