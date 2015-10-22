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
      organization: 'my_organization',
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

    it 'should generate a Formatronfile' do
      actual = File.read File.join(directory, 'Formatronfile')
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        name '#{params[:name]}'
        s3_bucket '#{params[:s3_bucket]}'

        bootstrap do
          kms_key '#{params[:kms_key]}'
          hosted_zone_id '#{params[:hosted_zone_id]}'

          ec2 do
            key_pair '#{params[:ec2_key_pair]}'
            private_key 'ec2/private_key.pem'
          end

          target 'target1' do
            protect #{params[:targets][:target1][:protect]}
          end

          target 'target2' do
            protect #{params[:targets][:target2][:protect]}
          end

          vpc do
            cidr '10.0.0.0/24'

            subnet 'management_1' do
              availability_zone '#{params[:availability_zone]}'
              cidr '10.0.0.0/16'
              public do
                restrict_source_ip [
                  '#{Curl.get('http://whatismyip.akamai.com').body_str}'
                ]
              end
            end

            subnet 'public_1' do
              availability_zone '#{params[:availability_zone]}'
              cidr '10.0.1.0/16'
              public
            end

            subnet 'private_1' do
              availability_zone '#{params[:availability_zone]}'
              cidr '10.0.2.0/16'
            end
          end

          bastion do
            subnet 'management_1'
            sub_domain config['bastion']['sub_domain']
            instance_cookbook 'bastion_instance'
          end

          nat do
            subnet 'public_1'
            sub_domain config['nat']['sub_domain']
            instance_cookbook 'nat_instance'
          end

          chef_server do
            subnet 'private_1'
            sub_domain config['chef_server']['sub_domain']
            instance_cookbook 'chef_server_instance'
            organization '#{params[:chef_server][:organization]}'
            username '#{params[:chef_server][:username]}'
            email '#{params[:chef_server][:email]}'
            first_name '#{params[:chef_server][:first_name]}'
            last_name '#{params[:chef_server][:last_name]}'
            password '#{params[:chef_server][:password]}'
            ssl_key config['chef_server']['ssl']['key']
            ssl_cert config['chef_server']['ssl']['cert']
            ssl_verify config['chef_server']['ssl']['verify']
          end
        end
      EOH
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
          "bastion": {
            "sub_domain": "bastion-target1"
          },
          "nat": {
            "sub_domain": "nat-target1"
          },
          "chef_server": {
            "sub_domain": "chef-target1"
          }
        }
      EOH
      actual = File.read File.join(directory, 'config/target2/_default.json')
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        {
          "bastion": {
            "sub_domain": "bastion-target2"
          },
          "nat": {
            "sub_domain": "nat-target2"
          },
          "chef_server": {
            "sub_domain": "chef-target2"
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
        'instance_cookbooks/chef_server_instance/metadata.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        name 'chef_server_instance'
        version '0.1.0'
        supports 'ubuntu'
      EOH
      actual = File.read File.join(
        directory,
        'instance_cookbooks/chef_server_instance/Berksfile'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        source 'https://supermarket.chef.io'

        metadata
      EOH
      actual = File.read File.join(
        directory,
        'instance_cookbooks/chef_server_instance/README.md'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        # chef_server_instance

        Cookbook to perform additional configuration on the Chef Server instance
      EOH
      actual = File.read File.join(
        directory,
        'instance_cookbooks/chef_server_instance/recipes/default.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
      EOH
    end

    it 'should add a nat_instance cookbook stub' do
      actual = File.read File.join(
        directory,
        'instance_cookbooks/nat_instance/metadata.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        name 'nat_instance'
        version '0.1.0'
        supports 'ubuntu'
      EOH
      actual = File.read File.join(
        directory,
        'instance_cookbooks/nat_instance/Berksfile'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        source 'https://supermarket.chef.io'

        metadata
      EOH
      actual = File.read File.join(
        directory,
        'instance_cookbooks/nat_instance/README.md'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        # nat_instance

        Cookbook to perform additional configuration on the NAT instance
      EOH
      actual = File.read File.join(
        directory,
        'instance_cookbooks/nat_instance/recipes/default.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
      EOH
    end

    it 'should add a bastion_instance cookbook stub' do
      actual = File.read File.join(
        directory,
        'instance_cookbooks/bastion_instance/metadata.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        name 'bastion_instance'
        version '0.1.0'
        supports 'ubuntu'
      EOH
      actual = File.read File.join(
        directory,
        'instance_cookbooks/bastion_instance/Berksfile'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        source 'https://supermarket.chef.io'

        metadata
      EOH
      actual = File.read File.join(
        directory,
        'instance_cookbooks/bastion_instance/README.md'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
        # bastion_instance

        Cookbook to perform additional configuration on the Bastion instance
      EOH
      actual = File.read File.join(
        directory,
        'instance_cookbooks/bastion_instance/recipes/default.rb'
      )
      expect(actual).to eql <<-EOH.gsub(/^ {8}/, '')
      EOH
    end
  end
end
