require 'coveralls'
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  minimum_coverage 20
end
Coveralls.wear_merged!
