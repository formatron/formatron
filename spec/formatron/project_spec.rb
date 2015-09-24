require 'spec_helper.rb'

require 'formatron/project'

describe Formatron::Project do
  include FakeFS::SpecHelpers

  before(:each) do
    @formatronfile = instance_double('Formatron::Formatronfile')
    formatronfile_class = class_double(
      'Formatron::Formatronfile'
    ).as_stubbed_const
    expect(formatronfile_class).to receive(:new).with(
      File.join('test', 'Formatronfile')
    ).once { @formatronfile }
    expect(@formatronfile).to receive(:name)
      .with(no_args).once { 'test_name' }
    expect(@formatronfile).to receive(:s3_bucket)
      .with(no_args).once { 'test_bucket' }
    expect(@formatronfile).to receive(:prefix)
      .with(no_args).once { 'test_prefix' }
    expect(@formatronfile).to receive(:kms_key)
      .with(no_args).once { 'test_kms_key' }

    @aws = instance_double('Formatron::Aws')
    aws_class = class_double('Formatron::Aws').as_stubbed_const
    expect(aws_class).to receive(:new).with(
      File.join('test', 'credentials.json')
    ).once { @aws }

    @config = instance_double('Formatron::Config')
    @config_class = class_double('Formatron::Config').as_stubbed_const
  end

  context 'with a super simple Formatron project' do
    it 'should initialize the config and aws object' do
      expect(@formatronfile).to receive(:depends)
        .with(no_args).once { [] }
      expect(@formatronfile).to receive(:opscode)
        .with(no_args).once { nil }

      expect(@config_class).to receive(:new).with(
        {
          name: 'test_name',
          target: 'test_target',
          s3_bucket: 'test_bucket',
          prefix: 'test_prefix',
          kms_key: 'test_kms_key'
        },
        File.join('test', 'config'),
        [],
        false
      ).once { @config }
      project = Formatron::Project.new(
        'test',
        'test_target'
      )

      expect(project.config).to equal(@config)
    end
  end

  context 'when there are dependencies' do
    it 'should intialize the dependency instances ' \
       'and pass them to the config' do
      expect(@formatronfile).to receive(:depends)
        .with(no_args).once { %w(dependency1 dependency2) }
      expect(@formatronfile).to receive(:opscode)
        .with(no_args).once { nil }

      dependency1 = instance_double('Formatron::Dependency')
      dependency2 = instance_double('Formatron::Dependency')
      dependency_class = class_double('Formatron::Dependency').as_stubbed_const
      expect(dependency_class).to receive(:new).with(
        @aws,
        name: 'dependency1',
        target: 'test_target',
        s3_bucket: 'test_bucket',
        prefix: 'test_prefix'
      ).once { dependency1 }
      expect(dependency_class).to receive(:new).with(
        @aws,
        name: 'dependency2',
        target: 'test_target',
        s3_bucket: 'test_bucket',
        prefix: 'test_prefix'
      ).once { dependency2 }

      expect(@config_class).to receive(:new).with(
        {
          name: 'test_name',
          target: 'test_target',
          s3_bucket: 'test_bucket',
          prefix: 'test_prefix',
          kms_key: 'test_kms_key'
        },
        File.join('test', 'config'), [
          dependency1,
          dependency2
        ], false
      ).once { @config }

      expect(Formatron::Project.new(
        'test',
        'test_target'
      ).config).to equal(@config)
    end
  end

  context 'when there is a cloudformation stack' do
    before(:each) do
      cloudformation_dir = File.join('test', 'cloudformation')
      FileUtils.mkdir_p(cloudformation_dir)
    end

    context 'and a cloudformation block in the Formatronfile' do
      before(:each) do
        @cloudformation_proc = proc { 'hello' }
        expect(@formatronfile).to receive(:depends)
          .with(no_args).once { [] }
        expect(@formatronfile).to receive(:cloudformation)
          .with(no_args).once { @cloudformation_proc }
        expect(@formatronfile).to receive(:opscode)
          .with(no_args).once { nil }
      end

      it 'should intialize the cloudformation instance ' \
         'and notify the config' do
        expect(@config_class).to receive(:new).with(
          {
            name: 'test_name',
            target: 'test_target',
            s3_bucket: 'test_bucket',
            prefix: 'test_prefix',
            kms_key: 'test_kms_key'
          },
          File.join('test', 'config'), [], true
        ).once { @config }

        cloudformation = instance_double('Formatron::Cloudformation')
        cloudformation_class = class_double(
          'Formatron::Cloudformation'
        ).as_stubbed_const
        expect(cloudformation_class).to receive(
          :new
        ).with(
          @config,
          @cloudformation_proc
        ).once { cloudformation }

        project = Formatron::Project.new(
          'test',
          'test_target'
        )
        expect(project.config).to equal(@config)
        expect(project.cloudformation).to equal(cloudformation)
      end
    end

    context 'but no cloudformation block in the Formatronfile' do
      before(:each) do
        @cloudformation_proc = proc { 'hello' }
        expect(@formatronfile).to receive(:depends)
          .with(no_args).once { [] }
        expect(@formatronfile).to receive(:cloudformation)
          .with(no_args).once { nil }
        expect(@formatronfile).to receive(:opscode)
          .with(no_args).once { nil }
      end

      it 'should intialize the cloudformation instance ' \
         'and notify the config' do
        expect(@config_class).to receive(:new).with(
          {
            name: 'test_name',
            target: 'test_target',
            s3_bucket: 'test_bucket',
            prefix: 'test_prefix',
            kms_key: 'test_kms_key'
          },
          File.join('test', 'config'), [], true
        ).once { @config }

        cloudformation = instance_double('Formatron::Cloudformation')
        cloudformation_class = class_double(
          'Formatron::Cloudformation'
        ).as_stubbed_const
        expect(cloudformation_class).to receive(
          :new
        ).with(
          @config,
          nil
        ).once { cloudformation }

        project = Formatron::Project.new(
          'test',
          'test_target'
        )
        expect(project.config).to equal(@config)
        expect(project.cloudformation).to equal(cloudformation)
      end
    end
  end

  context 'when there is an opscode block' do
    it 'should intialize the opscode instance ' do
      opscode_proc = proc { 'hello' }
      expect(@formatronfile).to receive(:depends)
        .with(no_args).once { [] }
      expect(@formatronfile).to receive(:opscode)
        .with(no_args).once { opscode_proc }

      expect(@config_class).to receive(:new).with(
        {
          name: 'test_name',
          target: 'test_target',
          s3_bucket: 'test_bucket',
          prefix: 'test_prefix',
          kms_key: 'test_kms_key'
        },
        File.join('test', 'config'), [], false
      ).once { @config }

      opscode = instance_double('Formatron::Opscode')
      opscode_class = class_double(
        'Formatron::Opscode'
      ).as_stubbed_const
      expect(opscode_class).to receive(
        :new
      ).with(
        @config,
        opscode_proc
      ).once { opscode }

      project = Formatron::Project.new(
        'test',
        'test_target'
      )
      expect(project.config).to equal(@config)
      expect(project.opscode).to equal(opscode)
    end
  end

  describe '#deploy' do
    it 'should put the config on S3 encrypted' do
      pending
      fail
    end

    context 'when there is an opscode configuration' do
      context 'and the chef server is defined in this stack' do
        context 'and the chef server needs to be deployed' do
          it 'should vendor the cookbooks and upload them ' \
             'to S3 with the lock file' do
            pending
            fail
          end
        end

        context 'and the chef server is already deployed' do
          it 'should deploy the cookbooks to the chef server' do
            pending
            fail
          end
        end
      end

      context 'and the chef server is not defined in this stack' do
        it 'should deploy the cookbooks to the chef server' do
          pending
          fail
        end
      end
    end

    context 'when there are opsworks cookbooks' do
      it 'should vendor the cookbooks and upload them to S3' do
        pending
        fail
      end
    end

    context 'when there is cloudformation configuration' do
      it 'should deploy a cloudformation stack' do
        pending
        fail
      end
    end
  end
end
