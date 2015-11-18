require 'formatron/external'

# rubocop:disable Metrics/ClassLength
class Formatron
  describe External do
    before :each do
      @target = 'target'
      @config = {
        'param1' => {
          'param1_1' => 'param1_1',
          'param1_2' => {
            'param1_2_1' => 'param1_2_1'
          }
        },
        'param2' => 'param2'
      }
      @aws = instance_double 'Formatron::AWS'
      @formatron = instance_double 'Formatron::DSL::Formatron'
      formatron_class = class_double(
        'Formatron::DSL::Formatron'
      ).as_stubbed_const
      allow(formatron_class).to receive(:new).with(
        external: nil
      ) { @formatron }
      @outputs = instance_double 'Formatron::External::Outputs'
      outputs_class = class_double(
        'Formatron::External::Outputs'
      ).as_stubbed_const
      allow(outputs_class).to receive(:new).with(
        aws: @aws,
        target: @target
      ) { @outputs }
      @external = External.new(
        aws: @aws,
        target: @target,
        config: @config
      )
    end

    describe '#formatron' do
      it 'should return the DSL formatron instance' do
        expect(@external.formatron).to eql @formatron
      end
    end

    describe '#outputs' do
      it 'should return the Outputs instance' do
        expect(@external.outputs).to eql @outputs
      end
    end

    describe '#export' do
      before :each do
        @local_formatron = 'formatron'
        @dsl_class = class_double(
          'Formatron::External::DSL'
        ).as_stubbed_const
        external_dsl = {
          external: 'external'
        }
        local_dsl = {
          internal: 'internal'
        }
        @merged_dsl = external_dsl.merge local_dsl
        allow(@dsl_class).to receive(:export).with(
          formatron: @formatron
        ) { external_dsl }
        allow(@dsl_class).to receive(:export).with(
          formatron: @local_formatron
        ) { local_dsl }
        @outputs_hash = 'outputs_hash'
        allow(@outputs).to receive(:hash) { @outputs_hash }
      end

      it 'should return the configuration to deploy' do
        expect(@external.export(formatron: @local_formatron)).to eql(
          'outputs' => @outputs_hash,
          'config' => @config,
          'dsl' => @merged_dsl
        )
      end
    end

    describe '#merge' do
      before :each do
        @outputs_configuration = 'outputs_configuration'
        @dsl_configuration = 'dsl_configuration'
        config_configuration0 = {
          'param1' => {
            'param1_1' => '0param1_1',
            'param1_2' => {
              'param1_2_1' => '0param1_2_1',
              'param1_2_2' => '0param1_2_2',
              'param1_2_3' => '0param1_2_3'
            },
            'param1_3' => '0param1_3',
            'param1_4' => '0param1_4'
          },
          'param2' => '0param2',
          'param3' => '0param3',
          'param4' => '0param4'
        }
        config_configuration1 = {
          'param1' => {
            'param1_1' => '1param1_1',
            'param1_2' => {
              'param1_2_1' => '1param1_2_1',
              'param1_2_2' => '1param1_2_2'
            },
            'param1_3' => '1param1_3'
          },
          'param2' => '1param2',
          'param3' => '1param3'
        }
        configuration0 = {
          'outputs' => @outputs_configuration,
          'dsl' => @dsl_configuration,
          'config' => config_configuration0
        }
        configuration1 = {
          'outputs' => @outputs_configuration,
          'dsl' => @dsl_configuration,
          'config' => config_configuration1
        }
        @bucket = 'bucket'
        @dependency0 = 'dependency0'
        @dependency1 = 'dependency1'
        allow(@outputs).to receive :merge
        configuration_class = class_double(
          'Formatron::S3::Configuration'
        ).as_stubbed_const
        allow(configuration_class).to receive(:get).with(
          aws: @aws,
          bucket: @bucket,
          name: @dependency0,
          target: @target
        ) { configuration0 }
        allow(configuration_class).to receive(:get).with(
          aws: @aws,
          bucket: @bucket,
          name: @dependency1,
          target: @target
        ) { configuration1 }
        @dsl_class = class_double(
          'Formatron::External::DSL'
        ).as_stubbed_const
        allow(@dsl_class).to receive :merge
        @external.merge bucket: @bucket, dependency: @dependency0
      end

      it 'should merge the CloudFormation outputs' do
        expect(@outputs).to have_received(:merge).with(
          dependency: @dependency0,
          configuration: @outputs_configuration
        )
      end

      it 'should merge the DSL configuration' do
        expect(@dsl_class).to have_received(:merge).with(
          formatron: @formatron,
          configuration: @dsl_configuration
        )
      end

      it 'should deep merge the config ensuring that ' \
         'the local config is always merged last' do
        @external.merge bucket: @bucket, dependency: @dependency1
        expect(@config).to eql(
          'param1' => {
            'param1_1' => 'param1_1',
            'param1_2' => {
              'param1_2_1' => 'param1_2_1',
              'param1_2_2' => '1param1_2_2',
              'param1_2_3' => '0param1_2_3'
            },
            'param1_3' => '1param1_3',
            'param1_4' => '0param1_4'
          },
          'param2' => 'param2',
          'param3' => '1param3',
          'param4' => '0param4'
        )
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
