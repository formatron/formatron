Gem::Specification.new do |s|
  s.name        = 'aws_deploy'
  s.version     = '0.0.0'
  s.executables = ['aws_deploy']
  s.date        = '2015-08-09'
  s.summary     = "AWS Deployment Tool"
  s.description = "AWS Deployment Tool"
  s.authors     = ["Peter Halliday"]
  s.email       = 'pghalliday@gmail.com'
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(README.md)
  s.homepage    =
    'https://github.com/pghalliday/aws_deploy'
  s.license       = 'MIT'
end
