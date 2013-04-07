# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'toque/version'

Gem::Specification.new do |spec|
  spec.name          = 'toque'
  spec.version       = Toque::VERSION
  spec.authors       = ['Jan Graichen']
  spec.email         = %w(jg@altimos.de)
  spec.description   = %q{Toque: Cap of a Chef. Integrate Chef into Capistrano.}
  spec.summary       = %q{Toque: Cap of a Chef. Integrate Chef into Capistrano.}
  spec.homepage      = 'https://github.com/jgraichen/toque'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'capistrano'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'capistrano-spec'
end
