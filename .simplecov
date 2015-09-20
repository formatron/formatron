require 'coveralls'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/features/'
  minimum_coverage 40
end
