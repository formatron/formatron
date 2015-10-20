require 'spec_helper'

require 'formatron/generators/bootstrap'

describe Formatron::Generators::Bootstrap do
  include FakeFS::SpecHelpers

  directory = 'test/directory'
  params = {
    name: 'bootstrap',
    hosted_zone_id: 'HOSTEDZONEID',
    kms_key: 'KMSKEY',
    s3_bucket: 'my_s3_bucket',
    organization: 'my_organization',
    username: 'my_username',
    email: 'my_email',
    first_name: 'my_first_name',
    last_name: 'my_last_name',
    targets: {
      'target1' => {
        protected: true,
        sub_domain: 'chef-1',
        password: 'password-1'
      },
      'target2' => {
        protected: false,
        sub_domain: 'chef-2',
        password: 'password-2'
      }
    }
  }

  describe '::generate' do
    before(:each) do
      lib = File.expand_path(
        File.join(
          File.dirname(File.expand_path(__FILE__)),
          '../../lib'
        )
      )
      FakeFS::FileSystem.clone lib
      Formatron::Generators::Bootstrap.generate directory, params
    end

    it 'should generate a README.md' do
      actual = File.read File.join(directory, 'README.md')
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        # #{params[:name]}

        Bootstrap Formatron configuration
      EOH
    end

    it 'should generate a Formatronfile' do
      actual = File.read File.join(directory, 'Formatronfile')
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        name '#{params[:name]}'
        s3_bucket '#{params[:s3_bucket]}'

        bootstrap do
          kms_key '#{params[:kms_key]}'
          ec2_key '#{params[:ec2_key]}'
          hosted_zone_id '#{params[:hosted_zone_id]}'
          organization '#{params[:organization]}'
          username '#{params[:username]}'
          email '#{params[:email]}'
          first_name '#{params[:first_name]}'
          last_name '#{params[:last_name]}'
          instance_cookbook 'chef_server_extra'
          target 'target1', {
            protected: #{params[:targets]['target1'][:protected]},
            sub_domain: '#{params[:targets]['target1'][:sub_domain]}',
            password: '#{params[:targets]['target1'][:password]}',
            ssl_key: 'ssl/target1/key',
            ssl_cert: 'ssl/target1/cert',
            ssl_verify: false
          }
          target 'target2', {
            protected: #{params[:targets]['target2'][:protected]},
            sub_domain: '#{params[:targets]['target2'][:sub_domain]}',
            password: '#{params[:targets]['target2'][:password]}',
            ssl_key: 'ssl/target2/key',
            ssl_cert: 'ssl/target2/cert',
            ssl_verify: false
          }
        end
      EOH
    end

    it 'should generate a config stub for each target' do
      empty_json = <<-EOH.gsub(/^ {8}/, '')
        {
        }
      EOH
      actual = File.read File.join(directory, 'config/_default/_default.json')
      expect(actual).to eql empty_json
      actual = File.read File.join(directory, 'config/target1/_default.json')
      expect(actual).to eql empty_json
      actual = File.read File.join(directory, 'config/target2/_default.json')
      expect(actual).to eql empty_json
    end

    it 'should add placeholders for the ssl certs, etc' do
      ssl_key_placeholder = "Remember to generate an SSL key\n"
      ssl_cert_placeholder = "Remember to generate an SSL certificate\n"
      actual = File.read File.join(directory, 'ssl/target1/key')
      expect(actual).to eql ssl_key_placeholder
      actual = File.read File.join(directory, 'ssl/target1/cert')
      expect(actual).to eql ssl_cert_placeholder
      actual = File.read File.join(directory, 'ssl/target2/key')
      expect(actual).to eql ssl_key_placeholder
      actual = File.read File.join(directory, 'ssl/target2/cert')
      expect(actual).to eql ssl_cert_placeholder
    end

    it 'should add a chef_server_extra cookbook stub' do
      actual = File.read File.join(
        directory,
        'instance_cookbooks/chef_server_extra/metadata.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        name 'chef_server_extra'
        version '0.1.0'
        supports 'ubuntu'
      EOH
      actual = File.read File.join(
        directory,
        'instance_cookbooks/chef_server_extra/Berksfile'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        source 'https://supermarket.chef.io'

        metadata
      EOH
      actual = File.read File.join(
        directory,
        'instance_cookbooks/chef_server_extra/README.md'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        # chef_server_extra

        Cookbook to perform additional configuration on the Chef Server
      EOH
      actual = File.read File.join(
        directory,
        'instance_cookbooks/chef_server_extra/recipes/default.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
      EOH
    end
  end
end
