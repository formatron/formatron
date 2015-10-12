$LOAD_PATH.unshift File.expand_path('../../../support', __FILE__)

require 'simplecov'
require 'json'
require 'cucumber/rspec/doubles'

require 's3_get_object_response'
require 'cloudformation_describe_stacks_response'
require 'formatron_stack'
require 'formatron_project'
