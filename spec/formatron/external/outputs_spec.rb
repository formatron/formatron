require 'formatron/external/outputs'

class Formatron
  # namespacing for tests
  class External
    describe Outputs do
      before :each do
        @aws = instance_double 'Formatron::AWS'
        @target = 'target'
        @outputs = Outputs.new aws: @aws, target: @target
      end

      describe '#merge/#hash' do
        before :each do
          dependency1 = 'dependency1'
          dependency2 = 'dependency2'
          outputs1 = {
            'output1' => '1output1',
            'output2' => '1output2'
          }
          outputs2 = {
            'output2' => '2output2',
            'output3' => '2output3'
          }
          @merged_outputs = {
            'output1' => '1output1',
            'output2' => '2output2',
            'output3' => '2output3'
          }
          cloud_formation_class = class_double(
            'Formatron::CloudFormation'
          ).as_stubbed_const
          allow(cloud_formation_class).to receive(:outputs).with(
            aws: @aws,
            name: dependency1,
            target: @target
          ) { outputs1 }
          allow(cloud_formation_class).to receive(:outputs).with(
            aws: @aws,
            name: dependency2,
            target: @target
          ) { outputs2 }
          @outputs.merge dependency: dependency1
          @outputs.merge dependency: dependency2
        end

        it 'should get the outputs from the CloudFormation ' \
           'stack and add them to the hash' do
          expect(@outputs.hash).to eql @merged_outputs
        end
      end
    end
  end
end
