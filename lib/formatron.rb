require_relative 'formatron/config'
require_relative 'formatron_util/tar'
require 'aws-sdk'
require 'json'
require 'pathname'
require 'erb'
require 'tempfile'

VENDOR_DIR = 'vendor'
CREDENTIALS_FILE = 'credentials.json'
CLOUDFORMATION_DIR = 'cloudformation'
OPSWORKS_DIR = 'opsworks'
OPSCODE_DIR = 'opscode'
MAIN_CLOUDFORMATION_JSON = 'main.json'

include FormatronUtil::Tar

class Formatron

  class TemplateParams
    def initialize(config)
      @config = config
    end
  end

  def initialize (dir, target)
    @dir = dir
    @target = target
    credentials_file = File.join(@dir, CREDENTIALS_FILE)
    credentials = JSON.parse(File.read(credentials_file))
    @credentials = Aws::Credentials.new(
      credentials['accessKeyId'],
      credentials['secretAccessKey']
    )
    @config = Formatron::Config.new @dir, @target, @credentials
  end

  def deploy
    s3 = Aws::S3::Client.new(
      region: @config.region,
      signature_version: 'v4',
      credentials: @credentials
    )
    config_s3_key = "#{@target}/#{@config.name}/config.json"
    response = s3.put_object(
      bucket: @config.s3_bucket,
      key: config_s3_key,
      body: @config.config.to_json,
      server_side_encryption: 'aws:kms',
      ssekms_key_id: @config.kms_key
    )
    opscode_dir = File.join(@dir, OPSCODE_DIR)
    if File.directory?(opscode_dir)
      user_key = "#{@target}/#{@config._opscode._user_key}"
      response = s3.get_object(
        bucket: @config.s3_bucket,
        key: user_key
      )
      tmp_user_key = Tempfile.new('formatron_chef_user_key')
      tmp_user_key.write(response.body.read)
      tmp_user_key.close
      tmp_knife_rb = Tempfile.new('formatron_knife_rb')
      tmp_knife_rb.write <<-EOH
        chef_server_url '#{@config._opscode._server_url}/organizations/#{@config._opscode._organization}'
        node_name '#{@config._opscode._user}'
        client_key '#{tmp_user_key.path}'
        ssl_verify_mode #{@config._opscode._ssl_self_signed_cert ? ':verify_none': ':verify_peer'}
      EOH
      tmp_knife_rb.close
      tmp_berkshelf_config = Tempfile.new('formatron_berkshelf_config')
      tmp_berkshelf_config.write <<-EOH
        {
          "chef": {
            "chef_server_url": "#{@config._opscode._server_url}/organizations/#{@config._opscode._organization}",
            "node_name": "#{@config._opscode._user}",
            "client_key": "#{tmp_user_key.path}"
          },
          "ssl": {
            "verify": #{@config._opscode._ssl_self_signed_cert ? 'false' : 'true'}
          }
        }
      EOH
      tmp_berkshelf_config.close
      begin
        Dir.glob(File.join(opscode_dir, '*')).each do |server|
          if File.directory?(server)
            server_name = File.basename(server)
            environment_name = "#{@config.name}__#{server_name}"
            %x(knife environment show #{environment_name} -c #{tmp_knife_rb.path})
            %x(knife environment create #{environment_name} -c #{tmp_knife_rb.path} -d '#{environment_name} environment created by formatron') unless $?.success?
            fail "failed to create opscode environment: #{environment_name}" unless $?.success?
            %x(berks install -c #{tmp_berkshelf_config.path} -b #{File.join(server, 'Berksfile')})
            fail "failed to download cookbooks for opscode server: #{server_name}" unless $?.success?
            %x(berks upload -c #{tmp_berkshelf_config.path} -b #{File.join(server, 'Berksfile')})
            fail "failed to upload cookbooks for opscode server: #{server_name}" unless $?.success?
            %x(berks apply #{environment_name} -c #{tmp_berkshelf_config.path} -b #{File.join(server, 'Berksfile.lock')})
            fail "failed to apply cookbooks to opscode environment: #{environment_name}" unless $?.success?
          end
        end
      ensure
        tmp_user_key.unlink
        tmp_knife_rb.unlink
        tmp_berkshelf_config.unlink
      end
    end
    opsworks_dir = File.join(@dir, OPSWORKS_DIR)
    opsworks_s3_key = "#{@target}/#{@config.name}/opsworks"
    if File.directory?(opsworks_dir)
      vendor_dir = File.join(@dir, VENDOR_DIR)
      FileUtils.rm_rf vendor_dir
      Dir.glob(File.join(opsworks_dir, '*')).each do |stack|
        if File.directory?(stack)
          stack_name = File.basename(stack)
          stack_vendor_dir = File.join(vendor_dir, stack_name)
          FileUtils.mkdir_p stack_vendor_dir
          %x(berks vendor -b #{File.join(stack, 'Berksfile')} #{stack_vendor_dir})
          fail "failed to vendor cookbooks for opsworks stack: #{stack_name}" unless $?.success?
          response = s3.put_object(
            bucket: @config.s3_bucket,
            key: "#{opsworks_s3_key}/#{stack_name}.tar.gz",
            body: gzip(tar(stack_vendor_dir))
          )
        end
      end
    end
    cloudformation_dir = File.join(@dir, CLOUDFORMATION_DIR)
    if File.directory?(cloudformation_dir)
      cloudformation = Aws::CloudFormation::Client.new(
        region: @config.region,
        credentials: @credentials
      )
      cloudformation_pathname = Pathname.new cloudformation_dir
      cloudformation_s3_key= "#{@target}/#{@config.name}/cloudformation"
      main = nil
      # upload plain json templates
      Dir.glob(File.join(cloudformation_dir, '**/*.json')) do |template|
        template_pathname = Pathname.new template
        template_json = File.read template
        response = cloudformation.validate_template(
          template_body: template_json
        )
        relative_path = template_pathname.relative_path_from(cloudformation_pathname)
        response = s3.put_object(
          bucket: @config.s3_bucket,
          key: "#{cloudformation_s3_key}/#{relative_path}",
          body: template_json,
        )
        main = JSON.parse(template_json) if relative_path.to_s.eql?(MAIN_CLOUDFORMATION_JSON)
      end
      # process and upload erb templates
      Dir.glob(File.join(cloudformation_dir, '**/*.json.erb')) do |template|
        template_pathname = Pathname.new File.join(File.dirname(template), File.basename(template, '.erb'))
        erb = ERB.new(File.read(template))
        erb.filename = template
        erbTemplate = erb.def_class(TemplateParams, 'render()')
        template_json = erbTemplate.new(@config.config).render()
        response = cloudformation.validate_template(
          template_body: template_json
        )
        relative_path = template_pathname.relative_path_from(cloudformation_pathname)
        response = s3.put_object(
          bucket: @config.s3_bucket,
          key: "#{cloudformation_s3_key}/#{relative_path}",
          body: template_json,
        )
        main = JSON.parse(template_json) if relative_path.to_s.eql?(MAIN_CLOUDFORMATION_JSON)
      end
      cloudformation_s3_root_url = "https://s3.amazonaws.com/#{@config.s3_bucket}/#{cloudformation_s3_key}"
      template_url = "#{cloudformation_s3_root_url}/#{MAIN_CLOUDFORMATION_JSON}"
      capabilities = ["CAPABILITY_IAM"]
      main_keys = main['Parameters'].keys
      parameters = main_keys.map do |key|
        case key
        when 'formatronName'
          {
            parameter_key: key,
            parameter_value: @config.name,
            use_previous_value: false
          }
        when 'formatronTarget'
          {
            parameter_key: key,
            parameter_value: @config.target,
            use_previous_value: false
          }
        when 'formatronPrefix'
          {
            parameter_key: key,
            parameter_value: @config.prefix,
            use_previous_value: false
          }
        when 'formatronS3Bucket'
          {
            parameter_key: key,
            parameter_value: @config.s3_bucket,
            use_previous_value: false
          }
        when 'formatronRegion'
          {
            parameter_key: key,
            parameter_value: @config.region,
            use_previous_value: false
          }
        when 'formatronKmsKey'
          {
            parameter_key: key,
            parameter_value: @config.kms_key,
            use_previous_value: false
          }
        when 'formatronConfigS3Key'
          {
            parameter_key: key,
            parameter_value: config_s3_key,
            use_previous_value: false
          }
        when 'formatronCloudformationS3Key'
          {
            parameter_key: key,
            parameter_value: cloudformation_s3_key,
            use_previous_value: false
          }
        when 'formatronOpsworksS3Key'
          {
            parameter_key: key,
            parameter_value: opsworks_s3_key,
            use_previous_value: false
          }
        else
          fail "No value specified for parameter: #{key}" if @config._cloudformation.nil? || @config._cloudformation.parameters[key].nil?
          {
            parameter_key: key,
            parameter_value: @config._cloudformation.parameters[key].to_s,
            use_previous_value: false
          }
        end
      end
      begin
        response = cloudformation.create_stack(
          stack_name: "#{@config.prefix}-#{@config.name}-#{@target}",
          template_url: template_url,
          capabilities: capabilities,
          on_failure: "DO_NOTHING",
          parameters: parameters
        )
      rescue Aws::CloudFormation::Errors::AlreadyExistsException
        begin
          response = cloudformation.update_stack(
            stack_name: "#{@config.prefix}-#{@config.name}-#{@target}",
            template_url: template_url,
            capabilities: capabilities,
            parameters: parameters
          )
        rescue Aws::CloudFormation::Errors::ValidationError => error
          raise error unless error.message.eql?('No updates are to be performed.')
        end
        # TODO: wait for the update to finish and then update the opsworks stacks
      end
    end
  end

end
