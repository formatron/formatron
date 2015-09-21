require 'coveralls'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/features/'
  add_filter '/support/'
  minimum_coverage 100
end
