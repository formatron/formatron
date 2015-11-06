class Formatron
  module Generators
    module Bootstrap
      # generates placeholder cookbooks
      module Cookbook
        def self.write(directory, name, description)
          cookbook_directory = File.join(
            directory,
            'cookbooks',
            name
          )
          _write_cookbook_metadata cookbook_directory, name
          _write_cookbook_readme cookbook_directory, name, description
          _write_cookbook_berksfile cookbook_directory
          _write_cookbook_recipe cookbook_directory
        end

        def self._write_cookbook_metadata(directory, name)
          FileUtils.mkdir_p directory
          metadata = File.join directory, 'metadata.rb'
          File.write metadata, <<-EOH.gsub(/^ {12}/, '')
            name '#{name}'
            version '0.1.0'
            supports 'ubuntu'
          EOH
        end

        def self._write_cookbook_readme(directory, name, description)
          FileUtils.mkdir_p directory
          readme = File.join directory, 'README.md'
          File.write readme, <<-EOH.gsub(/^ {12}/, '')
            # #{name}

            Cookbook to perform additional configuration on the #{description}
          EOH
        end

        def self._write_cookbook_berksfile(directory)
          FileUtils.mkdir_p directory
          berksfile = File.join directory, 'Berksfile'
          File.write berksfile, <<-EOH.gsub(/^ {12}/, '')
            source 'https://supermarket.chef.io'

            metadata
          EOH
        end

        def self._write_cookbook_recipe(directory)
          recipes_directory = File.join directory, 'recipes'
          FileUtils.mkdir_p recipes_directory
          recipe = File.join recipes_directory, 'default.rb'
          File.write recipe, <<-EOH.gsub(/^ {12}/, '')
          EOH
        end

        private_class_method(
          :_write_cookbook_metadata,
          :_write_cookbook_readme,
          :_write_cookbook_berksfile,
          :_write_cookbook_recipe
        )
      end
    end
  end
end
