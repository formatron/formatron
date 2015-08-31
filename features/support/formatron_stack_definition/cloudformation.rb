class Formatron::Features::Support::FormatronStackDefinition::Cloudformation
  CLOUDFORMATION_FILE = 'cloudformation/main.json'

  def initialize(dir)
    cloudformation_file = File.join(dir, CLOUDFORMATION_FILE)
    FileUtils.mkdir_p File.dirname(cloudformation_file)
    File.write cloudformation_file, <<-EOH.gsub(/^ {6}/, '')
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "test",
        "Parameters": {
          "param": {
            "Type": "String"
          }
        },
        "Resources": {
          "user": {
            "Type": "AWS::IAM::User",
            "Properties": {
              "LoginProfile": {
                "Password": { "Ref": "param" }
              }
            }
          }
        },
        "Outputs": {}
      }
    EOH
  end
end
