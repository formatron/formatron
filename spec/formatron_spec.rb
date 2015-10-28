require 'spec_helper'

require 'formatron'

describe Formatron do
  directory = 'test/directory'
  credentials = 'test/credentials'

  before(:each) do
    @aws_class = class_double(
      'Formatron::AWS'
    ).as_stubbed_const
    @aws = instance_double('Formatron::AWS')
    allow(@aws_class).to receive(:new) { @aws }

    @configuration_class = class_double(
      'Formatron::Configuration'
    ).as_stubbed_const
    @configuration = instance_double('Formatron::Configuration')
    allow(@configuration_class).to receive(:new) { @configuration }

    @formatron = Formatron.new(
      credentials,
      directory
    )
  end

  describe('::new') do
    it 'should create an AWS instance' do
      expect(@aws_class).to have_received(:new).once.with(credentials)
    end

    it 'should create a Configuration instance' do
      expect(@configuration_class).to have_received(:new).once.with(
        @aws,
        directory
      )
    end
  end

  describe '#targets' do
    it 'should get the list of targets from the formatronfile' do
      targets = %w(target1 target2 target3)
      expect(@configuration).to receive(:targets).once.with(no_args) { targets }
      expect(@formatron.targets).to eql targets
    end
  end

  describe '#protected?' do
    it 'should return whether the target should be protected from changes' do
      expect(@configuration).to receive(:protected?)
        .once.with('target1') { true }
      expect(@formatron.protected?('target1')).to eql true
    end
  end

  describe '#deploy' do
    before(:each) do
      @s3_configuration = class_double(
        'Formatron::S3Configuration'
      ).as_stubbed_const
      allow(@s3_configuration).to receive(:deploy)

      @s3_cloud_formation_template = class_double(
        'Formatron::S3CloudFormationTemplate'
      ).as_stubbed_const
      allow(@s3_cloud_formation_template).to receive(:deploy)

      @cloud_formation_stack = class_double(
        'Formatron::CloudFormationStack'
      ).as_stubbed_const
      allow(@cloud_formation_stack).to receive(:deploy)

      @formatron.deploy 'target1'
    end

    it 'should upload the configuration to S3' do
      expect(@s3_configuration).to have_received(:deploy).once.with(
        @aws,
        @configuration,
        'target1'
      )
    end

    it 'should upload the CloudFormation template to S3' do
      expect(@s3_cloud_formation_template).to have_received(:deploy).once.with(
        @aws,
        @configuration,
        'target1'
      )
    end

    it 'should deploy the CloudFormation stack' do
      expect(@cloud_formation_stack).to have_received(:deploy).once.with(
        @aws,
        @configuration,
        'target1'
      )
    end
  end

  describe '#provision' do
    before(:each) do
      @chef_instances = class_double(
        'Formatron::ChefInstances'
      ).as_stubbed_const
      allow(@chef_instances).to receive(:provision)

      @formatron.provision 'target1'
    end

    it 'should provision the instances with Chef' do
      expect(@chef_instances).to have_received(:provision).once.with(
        @aws,
        @configuration,
        'target1'
      )
    end
  end

  describe '#destroy' do
    before(:each) do
      @s3_configuration = class_double(
        'Formatron::S3Configuration'
      ).as_stubbed_const
      allow(@s3_configuration).to receive(:destroy)

      @s3_cloud_formation_template = class_double(
        'Formatron::S3CloudFormationTemplate'
      ).as_stubbed_const
      allow(@s3_cloud_formation_template).to receive(:destroy)

      @cloud_formation_stack = class_double(
        'Formatron::CloudFormationStack'
      ).as_stubbed_const
      allow(@cloud_formation_stack).to receive(:destroy)

      @chef_instances = class_double(
        'Formatron::ChefInstances'
      ).as_stubbed_const
      allow(@chef_instances).to receive(:destroy)

      @formatron.destroy 'target1'
    end

    it 'should delete the configuration from S3' do
      expect(@s3_configuration).to have_received(:destroy).once.with(
        @aws,
        @configuration,
        'target1'
      )
    end

    it 'should delete the CloudFormation template from S3' do
      expect(@s3_cloud_formation_template).to have_received(:destroy).once.with(
        @aws,
        @configuration,
        'target1'
      )
    end

    it 'should destroy the CloudFormation stack' do
      expect(@cloud_formation_stack).to have_received(:destroy).once.with(
        @aws,
        @configuration,
        'target1'
      )
    end

    it 'should cleanup the Chef Server configuration for the instances' do
      expect(@chef_instances).to have_received(:destroy).once.with(
        @aws,
        @configuration,
        'target1'
      )
    end
  end
end
