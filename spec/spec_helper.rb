$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
require 'coveralls'

SimpleCov.minimum_coverage 20
Coveralls.wear!

require 'formatron'
require 'pry'
