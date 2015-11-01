$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../support', __FILE__)
require 'simplecov'
require 'pry'
require 'fakefs/spec_helpers'

require 's3_get_object_response'
require 'cloudformation_describe_stacks_response'
require 'route53_get_hosted_zone_response'
include Formatron::Support
