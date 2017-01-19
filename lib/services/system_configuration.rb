module SystemTrack
  
  class SystemConfiguration
    @@hash = nil
  
    def initialize
      if (!@@hash)
        puts File.dirname(__FILE__)
        debugger
        
        @@hash = YAML.load(File.open("#{File.dirname(__FILE__)}/../config/systems.yml", "rb"))
      end
    end
  
    def config
      return @@hash[ENV['RAILS_ENV']]
    end
  
    def address_for(service_sym)
      service_config = config[service_sym.to_s]
      raise "Service config not found for: #{service_sym.to_s}" if (service_config == nil)
      protocol = "http"
      protocol = "https" if service_config["secure"] == "true"
      address = "#{protocol}://#{service_config['host']}:#{service_config['port']}"
      return address
    end

  end
end