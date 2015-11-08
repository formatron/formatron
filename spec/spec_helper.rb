$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../support', __FILE__)
require 'simplecov'
require 'pry'
require 'fakefs/spec_helpers'

require 'cloudformation_describe_stacks_response'
require 'route53_get_hosted_zone_response'
require 'dsl_test'
require 'template_test'
include Formatron::Support
