class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        # Generates scripts for setting up instances with CloudFormation init
        module Scripts
          def self.hostname(sub_domain:, hosted_zone_name:)
            # rubocop:disable Metrics/LineLength
            <<-EOH.gsub(/^ {14}/, '')
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

          # rubocop:disable Metrics/MethodLength
          def self.nat(cidr:)
            # rubocop:disable Metrics/LineLength
            <<-EOH.gsub(/^ {14}/, '')
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
            EOH
            # rubocop:enable Metrics/LineLength
          end
          # rubocop:enable Metrics/MethodLength
        end
      end
    end
  end
end
