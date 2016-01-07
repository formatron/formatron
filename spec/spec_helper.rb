$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../support', __FILE__)
require 'simplecov'
require 'pry'
require 'fakefs/spec_helpers'

require 'cloudformation_describe_stacks_response'
require 's3_get_object_response'
require 's3_list_objects_response'
require 'route53_get_hosted_zone_response'
require 'dsl_test'
require 'template_test'
require 'ssh_data'
include Formatron::Support
