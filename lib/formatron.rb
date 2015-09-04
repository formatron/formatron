require_relative 'formatron/config'
require_relative 'formatron_util/tar'
require_relative 'formatron_util/berks'
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

class Formatron
  class TemplateParams
    def initialize(config)
      @config = config
    end
  end

  def initialize(dir, target)
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
    cloudformation = Aws::CloudFormation::Client.new(
      region: @config.region,
      credentials: @credentials
    )
    response = s3.put_object(
      bucket: @config.s3_bucket,
      key: @config.config['formatronConfigS3Key'],
      body: JSON.pretty_generate(@config.config),
      server_side_encryption: 'aws:kms',
      ssekms_key_id: @config.config['formatronKmsKey']
    )
    opscode_dir = File.join(@dir, OPSCODE_DIR)
    if File.directory?(opscode_dir)
      need_to_deploy_first = false
      if @config.opscode._deploys_chef_server
        # first check if the stack is already deployed and ready
        begin
          response = cloudformation.describe_stacks(
            stack_name: "#{@config.prefix}-#{@config.name}-#{@target}"
          )
          status = response.stacks[0].stack_status
          # rubocop:disable Metrics/LineLength
          fail "Chef server cloudformation stack is in an invalid state: #{status}" unless %w(
            ROLLBACK_COMPLETE
            CREATE_COMPLETE
            UPDATE_COMPLETE
            UPDATE_ROLLBACK_COMPLETE
          ).include?(status)
          # rubocop:enable Metrics/LineLength
        rescue Aws::CloudFormation::Errors::ValidationError => error
          # rubocop:disable Metrics/LineLength
          raise error.class, error.message unless error.message.eql?("Stack with id #{@config.prefix}-#{@config.name}-#{@target} does not exist")
          # rubocop:enable Metrics/LineLength
          need_to_deploy_first = true
        end
      end
      if need_to_deploy_first
        vendor_dir = File.join(@dir, VENDOR_DIR)
        FileUtils.rm_rf vendor_dir
        Dir.glob(File.join(opscode_dir, '*')).each do |server|
          next unless File.directory?(server)
          server_name = File.basename(server)
          server_vendor_dir = File.join(vendor_dir, server_name)
          server_cookbooks_dir = File.join(server_vendor_dir, 'cookbooks')
          FileUtils.mkdir_p server_vendor_dir
          # rubocop:disable Metrics/LineLength
          `berks vendor -b #{File.join(server, 'Berksfile')} #{server_cookbooks_dir}`
          fail "failed to vendor cookbooks for opscode server: #{server_name}" unless $CHILD_STATUS.success?
          `cp #{File.join(server, 'Berksfile.lock')} #{server_vendor_dir}`
          # rubocop:enable Metrics/LineLength
          response = s3.put_object(
            bucket: @config.s3_bucket,
            key: "#{@config.opscode_s3_key}/#{server_name}.tar.gz",
            body: FormatronUtil::Tar.gzip(
              FormatronUtil::Tar.tar(server_vendor_dir)
            )
          )
        end
      else
        user_key = "#{@target}/#{@config.opscode._user_key}"
        response = s3.get_object(
          bucket: @config.s3_bucket,
          key: user_key
        )
        tmp_user_key = Tempfile.new('formatron_chef_user_key')
        tmp_user_key.write(response.body.read)
        tmp_user_key.close
        tmp_knife_rb = Tempfile.new('formatron_knife_rb')
        # rubocop:disable Metrics/LineLength
        tmp_knife_rb.write <<-EOH
          chef_server_url '#{@config.opscode._server_url}/organizations/#{@config.opscode._organization}'
          node_name '#{@config.opscode._user}'
          client_key '#{tmp_user_key.path}'
          ssl_verify_mode #{@config.opscode._ssl_self_signed_cert ? ':verify_none' : ':verify_peer'}
        EOH
        # rubocop:enable Metrics/LineLength
        tmp_knife_rb.close
        tmp_berkshelf_config = Tempfile.new('formatron_berkshelf_config')
        # rubocop:disable Metrics/LineLength
        tmp_berkshelf_config.write <<-EOH
          {
            "chef": {
              "chef_server_url": "#{@config.opscode._server_url}/organizations/#{@config.opscode._organization}",
              "node_name": "#{@config.opscode._user}",
              "client_key": "#{tmp_user_key.path}"
            },
            "ssl": {
              "verify": #{@config.opscode._ssl_self_signed_cert ? 'false' : 'true'}
            }
          }
        EOH
        # rubocop:enable Metrics/LineLength
        tmp_berkshelf_config.close
        begin
          Dir.glob(File.join(opscode_dir, '*')).each do |server|
            next unless File.directory?(server)
            server_name = File.basename(server)
            environment_name = "#{@config.name}__#{server_name}"
            # rubocop:disable Metrics/LineLength
            `knife environment show #{environment_name} -c #{tmp_knife_rb.path}`
            `knife environment create #{environment_name} -c #{tmp_knife_rb.path} -d '#{environment_name} environment created by formatron'` unless $CHILD_STATUS.success?
            fail "failed to create opscode environment: #{environment_name}" unless $CHILD_STATUS.success?
            `berks install -c #{tmp_berkshelf_config.path} -b #{File.join(server, 'Berksfile')}`
            fail "failed to download cookbooks for opscode server: #{server_name}" unless $CHILD_STATUS.success?
            `berks upload -c #{tmp_berkshelf_config.path} -b #{File.join(server, 'Berksfile')}`
            fail "failed to upload cookbooks for opscode server: #{server_name}" unless $CHILD_STATUS.success?
            `berks apply #{environment_name} -c #{tmp_berkshelf_config.path} -b #{File.join(server, 'Berksfile.lock')}`
            fail "failed to apply cookbooks to opscode environment: #{environment_name}" unless $CHILD_STATUS.success?
            # rubocop:enable Metrics/LineLength
          end
        ensure
          tmp_user_key.unlink
          tmp_knife_rb.unlink
          tmp_berkshelf_config.unlink
        end
      end
    end
    opsworks_dir = File.join(@dir, OPSWORKS_DIR)
    if File.directory?(opsworks_dir)
      vendor_dir = File.join(@dir, VENDOR_DIR)
      FileUtils.rm_rf vendor_dir
      Dir.glob(File.join(opsworks_dir, '*')).each do |stack|
        next unless File.directory?(stack)
        stack_name = File.basename(stack)
        stack_vendor_dir = File.join(vendor_dir, stack_name)
        FileUtils.mkdir_p stack_vendor_dir
        FormatronUtil::Berks.vendor(
          File.join(stack, 'Berksfile'),
          stack_vendor_dir
        )
        s3_key = @config.config['formatronOpsworksS3Key']
        response = s3.put_object(
          bucket: @config.s3_bucket,
          key: "#{s3_key}/#{stack_name}.tar.gz",
          body: FormatronUtil::Tar.gzip(
            FormatronUtil::Tar.tar(stack_vendor_dir)
          )
        )
      end
    end
    cloudformation_dir = File.join(@dir, CLOUDFORMATION_DIR)
    return unless File.directory?(cloudformation_dir)
    cloudformation_pathname = Pathname.new cloudformation_dir
    main = nil
    # upload plain json templates
    Dir.glob(File.join(cloudformation_dir, '**/*.json')) do |template|
      template_pathname = Pathname.new template
      template_json = File.read template
      response = cloudformation.validate_template(
        template_body: template_json
      )
      relative_path = template_pathname.relative_path_from(
        cloudformation_pathname
      )
      s3_key = @config.config['formatronCloudformationS3Key']
      response = s3.put_object(
        bucket: @config.s3_bucket,
        key: "#{s3_key}/#{relative_path}",
        body: template_json
      )
      main = JSON.parse(template_json) if
        relative_path.to_s.eql?(MAIN_CLOUDFORMATION_JSON)
    end
    # process and upload erb templates
    Dir.glob(File.join(cloudformation_dir, '**/*.json.erb')) do |template|
      template_pathname = Pathname.new File.join(
        File.dirname(template),
        File.basename(template, '.erb')
      )
      erb = ERB.new(File.read(template))
      erb.filename = template
      erb_template = erb.def_class(TemplateParams, 'render()')
      template_json = erb_template.new(@config.config).render
      response = cloudformation.validate_template(
        template_body: template_json
      )
      relative_path = template_pathname.relative_path_from(
        cloudformation_pathname
      )
      s3_key = @config.config['formatronCloudformationS3Key']
      response = s3.put_object(
        bucket: @config.s3_bucket,
        key: "#{s3_key}/#{relative_path}",
        body: template_json
      )
      main = JSON.parse(template_json) if
        relative_path.to_s.eql?(MAIN_CLOUDFORMATION_JSON)
    end
    # rubocop:disable Metrics/LineLength
    cloudformation_s3_root_url = "https://s3.amazonaws.com/#{@config.s3_bucket}/#{@config.config['formatronCloudformationS3Key']}"
    # rubocop:enable Metrics/LineLength
    template_url = "#{cloudformation_s3_root_url}/#{MAIN_CLOUDFORMATION_JSON}"
    capabilities = ['CAPABILITY_IAM']
    main_keys = main['Parameters'].keys
    parameters = main_keys.map do |key|
      if %w(
        formatronName
        formatronTarget
        formatronPrefix
        formatronS3Bucket
        formatronRegion
        formatronKmsKey
        formatronConfigS3Key
        formatronCloudformationS3Key
        formatronOpsworksS3Key
        formatronOpscodeS3Key
      ).include?(key)
        {
          parameter_key: key,
          parameter_value: @config.config[key],
          use_previous_value: false
        }
      else
        fail(
          "No value specified for parameter: #{key}"
        ) if
          @config.cloudformation.nil? ||
          @config.cloudformation.parameters[key].nil?
        {
          parameter_key: key,
          parameter_value: @config.cloudformation.parameters[key].to_s,
          use_previous_value: false
        }
      end
    end
    begin
      response = cloudformation.create_stack(
        stack_name: "#{@config.prefix}-#{@config.name}-#{@target}",
        template_url: template_url,
        capabilities: capabilities,
        on_failure: 'DO_NOTHING',
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
        raise error unless error.message.eql?(
          'No updates are to be performed.'
        )
      end
      # TODO: wait for the update to finish and
      # then update the opsworks stacks
    end
  end
end
