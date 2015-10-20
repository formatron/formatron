require_relative 'bootstrap/formatronfile'
require_relative 'bootstrap/config'
require_relative 'bootstrap/ssl'
require_relative 'bootstrap/instance_cookbook'
require_relative 'bootstrap/readme'

module Formatron
  module Generators
    # generates a bootstrap configuration
    module Bootstrap
      def self.generate(directory, params)
        Readme.write directory, params[:name]
        Formatronfile.write directory, params
        Config.write directory, '_default'
        params[:targets].each do |target, _|
          Config.write directory, target
          Ssl.write directory, target
        end
        InstanceCookbook.write directory
      end
    end
  end
end
