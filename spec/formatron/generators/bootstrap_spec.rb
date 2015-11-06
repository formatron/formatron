require 'spec_helper'
require 'curb'

require 'formatron/generators/bootstrap'

describe Formatron::Generators::Bootstrap do
  include FakeFS::SpecHelpers

  directory = 'test/directory'
  params = {
    name: 'bootstrap',
    hosted_zone_id: 'HOSTEDZONEID',
    kms_key: 'KMSKEY',
    ec2_key_pair: 'ec2-key-pair',
    availability_zone: 'a',
    s3_bucket: 'my_s3_bucket',
    chef_server: {
      cookbooks_bucket_prefix: 'cookbooks_bucket_prefix',
      organization: {
        short_name: 'my_organization',
        full_name: 'My Organization'
      },
      username: 'my_username',
      email: 'my_email',
      first_name: 'my_first_name',
      last_name: 'my_last_name',
      password: 'password'
    },
    targets: {
      target1: {
        protect: true
      },
      target2: {
        protect: false
      }
    }
  }

  describe '::generate' do
    before(:each) do
      lib = File.expand_path(
        File.join(
          File.dirname(File.expand_path(__FILE__)),
          '../../../lib'
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

    it 'should generate a .gitignore' do
      actual = File.read File.join(directory, '.gitignore')
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        /.formatron/
      EOH
    end

    it 'should generate an ec2/private-key.pem placeholder' do
      actual = File.read File.join(directory, 'ec2', 'private-key.pem')
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        Remember to replace this file with the EC2 private key
      EOH
    end

    it 'should generate a Formatronfile' do
      actual = File.read File.join(directory, 'Formatronfile')
      ip = Curl.get('http://whatismyip.akamai.com').body_str
      # rubocop:disable Metrics/LineLength
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        name '#{params[:name]}',
        bucket '#{params[:s3_bucket]}'

        bootstrap do |configuration|
          configuration.protect config['protected']
          configuration.kms_key '#{params[:kms_key]}'
          configuration.hosted_zone_id '#{params[:hosted_zone_id]}'

          configuration.ec2 do |ec2|
            ec2.key_pair '#{params[:ec2_key_pair]}'
            ec2.private_key 'ec2/private-key.pem'
          end

          configuration.vpc do |vpc|
            vpc.cidr '10.0.0.0/16'

            vpc.subnet 'management1' do |subnet|
              subnet.availability_zone '#{params[:availability_zone]}'
              subnet.cidr '10.0.0.0/24'
              subnet.public true do |acl|
                acl.source_cidr '#{ip}/32'
              end
            end

            vpc.subnet 'public1' do |subnet|
              subnet.availability_zone '#{params[:availability_zone]}'
              subnet.cidr '10.0.1.0/24'
              subnet.public true
            end

            vpc.subnet 'private1' do |subnet|
              subnet.availability_zone '#{params[:availability_zone]}'
              subnet.cidr '10.0.2.0/24'
            end
          end

          configuration.bastion do |bastion|
            bastion.subnet 'management1'
            bastion.sub_domain config['bastion']['sub_domain']
            bastion.cookbook 'cookbooks/bastion_instance'
          end

          configuration.nat do |nat|
            nat.subnet 'public1'
            nat.sub_domain config['nat']['sub_domain']
            nat.cookbook 'cookbooks/nat_instance'
          end

          configuration.chef_server do |chef_server|
            chef_server.version '12.2.0-1'
            chef_server.subnet 'management1'
            chef_server.sub_domain config['chef_server']['sub_domain']
            chef_server.cookbook 'cookbooks/chef_server_instance'
            chef_server.cookbooks_bucket config['chef_server']['cookbooks_bucket']
            chef_server.organization do |organization|
              organization.short_name '#{params[:chef_server][:organization][:short_name]}'
              organization.full_name '#{params[:chef_server][:organization][:full_name]}'
            end
            chef_server.username '#{params[:chef_server][:username]}'
            chef_server.email '#{params[:chef_server][:email]}'
            chef_server.first_name '#{params[:chef_server][:first_name]}'
            chef_server.last_name '#{params[:chef_server][:last_name]}'
            chef_server.password '#{params[:chef_server][:password]}'
            chef_server.ssl_key config['chef_server']['ssl']['key']
            chef_server.ssl_cert config['chef_server']['ssl']['cert']
            chef_server.ssl_verify config['chef_server']['ssl']['verify']
          end
        end
      EOH
      # rubocop:enable Metrics/LineLength
    end

    it 'should generate a config stub for each target' do
      actual = File.read File.join(directory, 'config/_default/_default.json')
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        {
        }
      EOH
      actual = File.read File.join(directory, 'config/target1/_default.json')
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        {
          "protected": true,
          "bastion": {
            "sub_domain": "bastion-target1"
          },
          "nat": {
            "sub_domain": "nat-target1"
          },
          "chef_server": {
            "sub_domain": "chef-target1",
            "cookbooks_bucket": "cookbooks_bucket_prefix-target1",
            "ssl": {
              "verify": true
            }
          }
        }
      EOH
      actual = File.read File.join(directory, 'config/target2/_default.json')
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        {
          "protected": false,
          "bastion": {
            "sub_domain": "bastion-target2"
          },
          "nat": {
            "sub_domain": "nat-target2"
          },
          "chef_server": {
            "sub_domain": "chef-target2",
            "cookbooks_bucket": "cookbooks_bucket_prefix-target2",
            "ssl": {
              "verify": true
            }
          }
        }
      EOH
    end

    it 'should add placeholders for the ssl certs, etc' do
      ssl_key_placeholder = "Remember to generate an SSL key\n"
      ssl_cert_placeholder = "Remember to generate an SSL certificate\n"
      actual = File.read File.join(
        directory,
        'config/target1/chef_server/ssl/key'
      )
      expect(actual).to eql ssl_key_placeholder
      actual = File.read File.join(
        directory,
        'config/target1/chef_server/ssl/cert'
      )
      expect(actual).to eql ssl_cert_placeholder
      actual = File.read File.join(
        directory,
        'config/target2/chef_server/ssl/key'
      )
      expect(actual).to eql ssl_key_placeholder
      actual = File.read File.join(
        directory,
        'config/target2/chef_server/ssl/cert'
      )
      expect(actual).to eql ssl_cert_placeholder
    end

    it 'should add a chef_server_instance cookbook stub' do
      actual = File.read File.join(
        directory,
        'cookbooks/chef_server_instance/metadata.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        name 'chef_server_instance'
        version '0.1.0'
        supports 'ubuntu'
      EOH
      actual = File.read File.join(
        directory,
        'cookbooks/chef_server_instance/Berksfile'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        source 'https://supermarket.chef.io'

        metadata
      EOH
      actual = File.read File.join(
        directory,
        'cookbooks/chef_server_instance/README.md'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        # chef_server_instance

        Cookbook to perform additional configuration on the Chef Server instance
      EOH
      actual = File.read File.join(
        directory,
        'cookbooks/chef_server_instance/recipes/default.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
      EOH
    end

    it 'should add a nat_instance cookbook stub' do
      actual = File.read File.join(
        directory,
        'cookbooks/nat_instance/metadata.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        name 'nat_instance'
        version '0.1.0'
        supports 'ubuntu'
      EOH
      actual = File.read File.join(
        directory,
        'cookbooks/nat_instance/Berksfile'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        source 'https://supermarket.chef.io'

        metadata
      EOH
      actual = File.read File.join(
        directory,
        'cookbooks/nat_instance/README.md'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        # nat_instance

        Cookbook to perform additional configuration on the NAT instance
      EOH
      actual = File.read File.join(
        directory,
        'cookbooks/nat_instance/recipes/default.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
      EOH
    end

    it 'should add a bastion_instance cookbook stub' do
      actual = File.read File.join(
        directory,
        'cookbooks/bastion_instance/metadata.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        name 'bastion_instance'
        version '0.1.0'
        supports 'ubuntu'
      EOH
      actual = File.read File.join(
        directory,
        'cookbooks/bastion_instance/Berksfile'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        source 'https://supermarket.chef.io'

        metadata
      EOH
      actual = File.read File.join(
        directory,
        'cookbooks/bastion_instance/README.md'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        # bastion_instance

        Cookbook to perform additional configuration on the Bastion instance
      EOH
      actual = File.read File.join(
        directory,
        'cookbooks/bastion_instance/recipes/default.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
      EOH
    end
  end
end
