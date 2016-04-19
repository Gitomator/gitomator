require 'gitomator'


module Gitomator


  #
  # Register service-factories, and create services.
  #
  class BaseContext

    #
    # @param config [Hash]
    #
    def initialize(config)
      @config = config
      @service2factory = {}
      @services = {}

      config.select { |_,v| v.is_a?(Hash) && v.has_key?('provider')}
        .each do |service, service_config|
          register_service(service.to_sym) do |config|
            self.send("create_#{config['provider']}_#{service}_service", config || {})
          end
        end

    end


    #
    # @param service [Symbol] The service's name.
    # @param block [Proc<Hash> -> Object] Given a config, create a service object.
    #
    def register_service(service, &block)
      @service2factory[service] = block

      # Create a lazy-loader getter for the service
      unless self.respond_to? service
        self.class.send(:define_method, service) do
          @services[service] ||= @service2factory[service].call(@config[service.to_s] || {})
        end
      end
    end

  end



  class Context < BaseContext


    #--------------------------------------------------------------------------------------
    # Static factory methods ...

    class << self
      private :new
    end

    #
    # @param config_file [String/File] - YAML configuration file.
    #
    def self.from_file(config_file)
      return from_hash(Gitomator::Util.load_config(config_file))
    end

    #
    # @param config [Hash] - Configuration data (e.g. parsed from a YAML file)
    #
    def self.from_hash(config)
      return new(config)
    end

    #--------------------------------------------------------------------------------------


    DEFAULT_CONFIG = {
      'git'     => { 'provider' => 'shell'},
      'hosting' => { 'provider' => 'local'}
    }

    def initialize(config={})
      super(DEFAULT_CONFIG.merge(config))
    end

    #--------------------------------------------------------------------------------------
    # Service factory methods ...


    def create_local_hosting_service(config)
      require 'gitomator/service/hosting'
      require 'gitomator/service_provider/hosting_local'
      require 'tmpdir'

      dir = config['dir'] || Dir.mktmpdir('Gitomator_')
      return Gitomator::Service::Hosting.new (
        Gitomator::ServiceProvider::HostingLocal.new(git, dir)
      )
    end


    def create_shell_git_service(_)
      require 'gitomator/service/git'
      require 'gitomator/service_provider/git_shell'
      Gitomator::Service::Git.new(Gitomator::ServiceProvider::GitShell.new())
    end


  end
end
