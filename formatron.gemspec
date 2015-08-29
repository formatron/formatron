# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'formatron/version'

Gem::Specification.new do |spec|
  spec.name          = 'formatron'
  spec.version       = Formatron::VERSION
  spec.authors       = ['Peter Halliday']
  spec.email         = ['pghalliday@gmail.com']

  if spec.respond_to?(:metadata)
  end

  spec.summary       = 'AWS/Chef Deployment Tool'

  spec.description   = <<-EOH
AWS/Chef deployment tool based around Chef Server and AWS CloudFormation
EOH

  spec.homepage      = 'https://github.com/pghalliday/formatron'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-nc'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-remote'
  spec.add_development_dependency 'pry-nav'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'guard-cucumber'

  spec.add_runtime_dependency 'aws-sdk', '~> 2.1'
  spec.add_runtime_dependency 'deep_merge', '~> 1.0'
  spec.add_runtime_dependency 'berkshelf', '~> 3.3'
  spec.add_runtime_dependency 'chef', '~> 12.4'
end
