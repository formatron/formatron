Gem::Specification.new do |s|
  s.name        = 'formatron'
  s.version     = '0.0.0'
  s.executables = ['formatron']
  s.date        = '2015-08-09'
  s.summary     = "AWS Deployment Tool"
  s.description = "AWS deployment tool supporting dependent cloudformation and opsworks stacks"
  s.authors     = ["Peter Halliday"]
  s.email       = 'pghalliday@gmail.com'
  s.files       = Dir.glob("{bin,lib,template}/**/*", File::FNM_DOTMATCH) + %w(README.md)
  s.homepage    =
    'https://github.com/pghalliday/formatron'
  s.license       = 'MIT'
  s.add_runtime_dependency 'aws-sdk', '~> 2.1'
  s.add_runtime_dependency 'deep_merge', '~> 1.0'
  s.add_runtime_dependency 'berkshelf', '~> 3.3'
end
