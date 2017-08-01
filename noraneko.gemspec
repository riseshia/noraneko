# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'noraneko/version'

Gem::Specification.new do |spec|
  spec.name          = 'noraneko'
  spec.version       = Noraneko::VERSION
  spec.authors       = ['Shia']
  spec.email         = ['rise.shia@gmail.com']

  spec.summary       = 'Find candidate which unused methods, views from rails app'
  spec.description   = 'Find candidate unused methods, views from rails app with static parse'
  spec.homepage      = 'https://github.com/riseshia/noraneko'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_dependency 'parser', '~> 2.4'
end
