require 'spec_helper'
require 'formatron/chef/berkshelf'

class Formatron
  # rubocop:disable Metrics/ModuleLength
  module Chef
    describe Berkshelf do
      before(:each) do
        @key_tempfile = instance_double('Tempfile')
        allow(@key_tempfile).to receive(:write)
        allow(@key_tempfile).to receive(:close)
        allow(@key_tempfile).to receive(:unlink)
        allow(@key_tempfile).to receive(:path) do
          'key_file'
        end
        @berks_tempfile = instance_double('Tempfile')
        allow(@berks_tempfile).to receive(:write)
        allow(@berks_tempfile).to receive(:close)
        allow(@berks_tempfile).to receive(:unlink)
        allow(@berks_tempfile).to receive(:path) do
          'berks_file'
        end
        @tempfile_class = class_double('Tempfile').as_stubbed_const
        allow(@tempfile_class).to receive(:new) do |name|
          case name
          when 'berks_key'
            @key_tempfile
          when 'berks'
            @berks_tempfile
          end
        end
        @file_utils = class_double('FileUtils').as_stubbed_const
        allow(@file_utils).to receive(:mkdir_p)
        allow(@file_utils).to receive(:cp)
        @kernel_helper_class = class_double(
          'Formatron::Util::KernelHelper'
        ).as_stubbed_const
        allow(@kernel_helper_class).to receive(:shell)
      end

      describe '::vendor' do
        context 'when adding the lock file to the vendored cookbooks' do
          before(:each) do
            allow(@kernel_helper_class).to receive(:success?) { true }
            Berkshelf.vendor('cookbook', 'vendor', true)
          end

          it 'should create a cookbooks directory ' \
             'inside the vendor directory' do
            expect(@file_utils).to have_received(:mkdir_p).once
            expect(@file_utils).to have_received(
              :mkdir_p
            ).with('vendor/cookbooks')
          end

          it 'should vendor the cookbboks to the cookbooks directory' do
            expect(@kernel_helper_class).to have_received(:shell).once
            expect(@kernel_helper_class).to have_received(:shell).with(
              'berks vendor -b cookbook/Berksfile vendor/cookbooks'
            )
          end

          it 'should copy the lock file to the vendor directory' do
            expect(@file_utils).to have_received(:cp).once
            expect(@file_utils).to have_received(:cp).with(
              'cookbook/Berksfile.lock',
              'vendor'
            )
          end
        end

        context 'when not adding the lock file to the vendored cookbooks' do
          before(:each) do
            allow(@kernel_helper_class).to receive(:success?) { true }
            Berkshelf.vendor('cookbook', 'vendor')
          end

          it 'should create the vendor directory' do
            expect(@file_utils).to have_received(:mkdir_p).once
            expect(@file_utils).to have_received(:mkdir_p).with('vendor')
          end

          it 'should vendor the cookbboks to the vendor directory' do
            expect(@kernel_helper_class).to have_received(:shell).once
            expect(@kernel_helper_class).to have_received(:shell).with(
              'berks vendor -b cookbook/Berksfile vendor'
            )
          end

          it 'should not copy the lock file to the vendor directory' do
            expect(@file_utils).not_to have_received(:cp)
          end
        end

        context 'when an error is encountered vendoring cookbooks' do
          before(:each) do
            allow(@kernel_helper_class).to receive(:success?) { false }
          end

          it 'should fail' do
            expect { Berkshelf.vendor('cookbook', 'vendor') }
              .to raise_error(Berkshelf::VendorError)
          end
        end
      end

      context 'when verifying SSL certs' do
        before(:each) do
          @knife = Berkshelf.new(
            'http://server',
            'user',
            'key',
            'organization',
            true
          )
        end

        it 'should create a temporary file for the berks ' \
           'config setting the verify mode to true' do
          expect(@tempfile_class).to have_received(:new).with('berks').once
          expect(@berks_tempfile).to have_received(:write).with(
            <<-EOH.gsub(/^\s{14}/, '')
              {
                "chef": {
                  "chef_server_url": "http://server/organizations/organization",
                  "node_name": "user",
                  "client_key": "key_file"
                },
                "ssl": {
                  "verify": true
                }
              }
            EOH
          ).once
          expect(@berks_tempfile).to have_received(:close).with(no_args).once
        end
      end

      context 'when not verifying SSL certs' do
        before(:each) do
          @berks = Berkshelf.new(
            'http://server',
            'user',
            'key',
            'organization',
            false
          )
        end

        it 'should create a temporary file for the berks ' \
           'config setting the verify mode to false' do
          expect(@tempfile_class).to have_received(:new).with('berks').once
          expect(@berks_tempfile).to have_received(:write).with(
            <<-EOH.gsub(/^\s{14}/, '')
              {
                "chef": {
                  "chef_server_url": "http://server/organizations/organization",
                  "node_name": "user",
                  "client_key": "key_file"
                },
                "ssl": {
                  "verify": false
                }
              }
            EOH
          ).once
          expect(@berks_tempfile).to have_received(:close).with(no_args).once
        end
      end

      it 'should create a temporary file for the chef key' do
        @berks = Berkshelf.new(
          'http://server',
          'user',
          'key',
          'organization',
          true
        )
        expect(@tempfile_class).to have_received(:new).with('berks_key').once
        expect(@key_tempfile).to have_received(:write).with('key').once
        expect(@key_tempfile).to have_received(:close).with(no_args).once
      end

      describe '#unlink' do
        before(:each) do
          @berks = Berkshelf.new(
            'http://server',
            'user',
            'key',
            'organization',
            true
          )
          @berks.unlink
        end

        it 'should delete the chef key file' do
          expect(@key_tempfile).to have_received(:unlink).with(no_args).once
        end

        it 'should delete the berks config file' do
          expect(@berks_tempfile).to have_received(:unlink).with(no_args).once
        end
      end

      describe '#upload_environment' do
        before(:each) do
          @berks = Berkshelf.new(
            'http://server',
            'user',
            'key',
            'organization',
            true
          )
        end

        context 'when the berks install fails' do
          before(:each) do
            allow(@kernel_helper_class).to receive(:shell) do |command|
              case command
              when 'berks install -b cookbook/Berksfile'
                allow(@kernel_helper_class).to receive(:success?) { false }
              else
                allow(@kernel_helper_class).to receive(:success?) { true }
              end
            end
          end

          it 'should fail' do
            expect { @berks.upload_environment 'cookbook', 'environment' }
              .to raise_error(
                Berkshelf::UploadEnvironmentError,
                'failed to download cookbooks for ' \
                'opscode environment: environment'
              )
          end
        end

        context 'when the berks upload fails' do
          before(:each) do
            allow(@kernel_helper_class).to receive(:shell) do |command|
              case command
              when 'berks upload -c berks_file -b cookbook/Berksfile'
                allow(@kernel_helper_class).to receive(:success?) { false }
              else
                allow(@kernel_helper_class).to receive(:success?) { true }
              end
            end
          end

          it 'should fail' do
            expect { @berks.upload_environment 'cookbook', 'environment' }
              .to raise_error(
                Berkshelf::UploadEnvironmentError,
                'failed to upload cookbooks for ' \
                'opscode environment: environment'
              )
          end
        end

        context 'when the berks apply fails' do
          before(:each) do
            allow(@kernel_helper_class).to receive(:shell) do |command|
              case command
              when 'berks apply environment -c berks_file ' \
                   '-b cookbook/Berksfile.lock'
                allow(@kernel_helper_class).to receive(:success?) { false }
              else
                allow(@kernel_helper_class).to receive(:success?) { true }
              end
            end
          end

          it 'should fail' do
            expect { @berks.upload_environment 'cookbook', 'environment' }
              .to raise_error(
                Berkshelf::UploadEnvironmentError,
                'failed to apply cookbooks to opscode environment: environment'
              )
          end
        end

        context 'when all the berks commands succeed' do
          before(:each) do
            allow(@kernel_helper_class).to receive(:shell)
            allow(@kernel_helper_class).to receive(:success?) { true }
            @berks.upload_environment 'cookbook', 'environment'
          end

          it 'should install cookbooks' do
            expect(@kernel_helper_class).to have_received(:shell).with(
              'berks install -b cookbook/Berksfile'
            ).once
          end

          it 'should upload cookbooks' do
            expect(@kernel_helper_class).to have_received(:shell).with(
              'berks upload -c berks_file -b cookbook/Berksfile'
            ).once
          end

          it 'should apply cookbooks to the environment' do
            expect(@kernel_helper_class).to have_received(:shell).with(
              'berks apply environment -c berks_file -b cookbook/Berksfile.lock'
            ).once
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
