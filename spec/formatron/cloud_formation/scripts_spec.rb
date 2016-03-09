require 'spec_helper'
require 'formatron/cloud_formation/scripts'

class Formatron
  # namespacing for tests
  # rubocop:disable Metrics/ModuleLength
  module CloudFormation
    describe Scripts do
      describe '::linux_common' do
        it 'should return a script that sets the hostname, etc' do
          sub_domain = 'sub_domain'
          hosted_zone_name = 'hosted_zone_name'
          expect(
            Scripts.linux_common(
              sub_domain: sub_domain,
              hosted_zone_name: hosted_zone_name
            )
          # rubocop:disable Metrics/LineLength
          ).to eql <<-EOH.gsub(/^ {12}/, '')
            #/bin/bash -v
            set -e
            SHORTNAME=#{sub_domain}
            PUBLIC_DNS=${SHORTNAME}.#{hosted_zone_name}
            PRIVATE_IPV4=`(curl http://169.254.169.254/latest/meta-data/local-ipv4)`
            hostname $SHORTNAME
            echo $PUBLIC_DNS | tee /etc/hostname
            echo "$PRIVATE_IPV4 $PUBLIC_DNS $SHORTNAME" >> /etc/hosts
          EOH
          # rubocop:enable Metrics/LineLength
        end
      end

      describe '::windows_common' do
        it 'should return a script that sets the hostname' do
          sub_domain = 'sub_domain'
          hosted_zone_name = 'hosted_zone_name'
          expect(
            Scripts.windows_common(
              sub_domain: sub_domain,
              hosted_zone_name: hosted_zone_name
            )
          # rubocop:disable Metrics/LineLength
          ).to eql <<-EOH.gsub(/^ {12}/, '')
            REG ADD HKLM\\SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ComputerName /v ComputerName /t REG_SZ /d #{sub_domain} /f
            REG ADD HKLM\\SYSTEM\\CurrentControlSet\\services\\Tcpip\\Parameters /v Domain /t REG_SZ /d #{hosted_zone_name} /f
            shutdown.exe /r /t 00
          EOH
          # rubocop:enable Metrics/LineLength
        end
      end

      describe '::windows_signal' do
        it 'should return a script that signals success' do
          wait_condition_handle = 'wait_condition_handle'
          expect(
            Scripts.windows_signal(
              wait_condition_handle: wait_condition_handle
            )
          ).to eql(
            'Fn::Base64' => {
              'Fn::Join' => [
                '', [
                  'cfn-signal.exe -e 0 ',
                  {
                    'Fn::Base64' => {
                      Ref: wait_condition_handle
                    }
                  }
                ]
              ]
            }
          )
        end
      end

      describe '::nat' do
        it 'should return a script that sets up a NAT' do
          cidr = 'cidr'
          # rubocop:disable Metrics/LineLength
          expect(Scripts.nat(cidr: cidr)).to eql <<-EOH.gsub(/^ {12}/, '')
            #/bin/bash -v
            set -e
            if ! grep --quiet '^net.ipv4.ip_forward=1$' /etc/sysctl.conf; then
              sed -i '/^#net.ipv4.ip_forward=1$/c\\net.ipv4.ip_forward=1' /etc/sysctl.conf
              sysctl -p /etc/sysctl.conf
            fi
            iptables -t nat -A POSTROUTING -o eth0 -s #{cidr} -j MASQUERADE
            iptables-save > /etc/iptables.rules
            cat << EOF > /etc/network/if-pre-up.d/iptablesload
            #!/bin/sh
            iptables-restore < /etc/iptables.rules
            exit 0
            EOF
            chmod +x /etc/network/if-pre-up.d/iptablesload
          EOH
          # rubocop:enable Metrics/LineLength
        end
      end

      describe '::chef_server' do
        it 'should return a script that sets up a Chef Server' do
          username = 'username'
          first_name = 'first_name'
          last_name = 'last_name'
          email = 'email'
          password = 'password'
          organization_short_name = 'organization_short_name'
          organization_full_name = 'organization_full_name'
          bucket = 'bucket'
          user_pem_key = 'user_pem_key'
          organization_pem_key = 'organization_pem_key'
          kms_key = 'kms_key'
          chef_server_version = 'chef_server_version'
          ssl_cert_key = 'ssl_cert_key'
          ssl_key_key = 'ssl_key_key'
          cookbooks_bucket = 'cookbooks_bucket'
          # rubocop:disable Metrics/LineLength
          expect(
            Scripts.chef_server(
              username: username,
              first_name: first_name,
              last_name: last_name,
              email: email,
              password: password,
              organization_short_name: organization_short_name,
              organization_full_name: organization_full_name,
              bucket: bucket,
              user_pem_key: user_pem_key,
              organization_pem_key: organization_pem_key,
              kms_key: kms_key,
              chef_server_version: chef_server_version,
              ssl_cert_key: ssl_cert_key,
              ssl_key_key: ssl_key_key,
              cookbooks_bucket: cookbooks_bucket
            )
          ).to eql <<-EOH.gsub(/^ {12}/, '')
            #!/bin/bash -v

            set -e

            export HOME=/root
            export PATH=$PATH:/usr/local/sbin/
            export PATH=$PATH:/usr/sbin/
            export PATH=$PATH:/sbin

            apt-get -y update
            apt-get -y install wget ntp cron git libfreetype6 libpng3 python-pip
            pip install awscli

            mkdir -p $HOME/.aws
            cat << EOF > $HOME/.aws/config
            [default]
            s3 =
                signature_version = s3v4
            region = ${REGION}
            EOF

            mkdir -p /etc/opscode/chef-server.rb.d

            cat << EOF > /etc/opscode/chef-server.rb
            Dir[File.dirname(__FILE__) + '/chef-server.rb.d/*.rb'].each do |file|
              self.instance_eval File.read(file), file
            end
            EOF

            cat << EOF > /etc/opscode/chef-server.rb.d/s3_cookbooks_bucket.rb
            bookshelf['enable'] = false
            bookshelf['external_url'] = 'https://s3-${REGION}.amazonaws.com'
            bookshelf['vip'] = 's3-${REGION}.amazonaws.com'
            bookshelf['access_key_id'] = '${ACCESS_KEY_ID}'
            bookshelf['secret_access_key'] = '${SECRET_ACCESS_KEY}'
            opscode_erchef['s3_bucket'] = '#{cookbooks_bucket}'
            EOF

            cat << EOF > /etc/opscode/chef-server.rb.d/ssl_certificate.rb
            nginx['ssl_certificate'] = '/etc/nginx/ssl/chef.crt'
            nginx['ssl_certificate_key'] = '/etc/nginx/ssl/chef.key'
            EOF

            mkdir -p /etc/nginx/ssl
            aws s3api get-object --bucket #{bucket} --key #{ssl_cert_key} /etc/nginx/ssl/chef.crt
            aws s3api get-object --bucket #{bucket} --key #{ssl_key_key} /etc/nginx/ssl/chef.key

            wget -O /tmp/chef-server-core.deb https://web-dl.packagecloud.io/chef/stable/packages/ubuntu/trusty/chef-server-core_#{chef_server_version}_amd64.deb
            dpkg -i /tmp/chef-server-core.deb

            chef-server-ctl reconfigure >> /var/log/chef-install.log
            chef-server-ctl user-create #{username} #{first_name} #{last_name} #{email} #{password} --filename $HOME/user.pem >> /var/log/chef-install.log
            chef-server-ctl org-create #{organization_short_name} "#{organization_full_name}" --association_user #{username} --filename $HOME/organization.pem >> /var/log/chef-install.log

            chef-server-ctl install opscode-manage >> /var/log/chef-install.log
            chef-server-ctl reconfigure >> /var/log/chef-install.log
            opscode-manage-ctl reconfigure >> /var/log/chef-install.log

            chef-server-ctl install opscode-push-jobs-server >> /var/log/chef-install.log
            chef-server-ctl reconfigure >> /var/log/chef-install.log
            opscode-push-jobs-server-ctl reconfigure >> /var/log/chef-install.log

            chef-server-ctl install opscode-reporting >> /var/log/chef-install.log
            chef-server-ctl reconfigure >> /var/log/chef-install.log
            opscode-reporting-ctl reconfigure >> /var/log/chef-install.log

            aws s3api put-object --bucket #{bucket} --key #{user_pem_key} --body $HOME/user.pem --ssekms-key-id #{kms_key} --server-side-encryption aws:kms
            aws s3api put-object --bucket #{bucket} --key #{organization_pem_key} --body $HOME/organization.pem --ssekms-key-id #{kms_key} --server-side-encryption aws:kms
          EOH
          # rubocop:enable Metrics/LineLength
        end
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
