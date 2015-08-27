$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
require 'coveralls'

SimpleCov.minimum_coverage 100
Coveralls.wear!

require 'formatron'
require 'pry'
