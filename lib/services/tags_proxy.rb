require_relative "./proxy_base"

module SystemTrack
  class TagsProxy < ProxyBase

    def initialize
    end
  
    def service_connection
      address = SystemConfiguration.new.address_for(:machine)
      return connection(address)
    end

    def create_tag(session, tag_hash)
      credentials = session[:credentials]
      response = service_connection.post "/api/v1/tags/save", {credentials: credentials, tag: tag_hash}
      return_json = JSON.parse(response.body)
    end
  
  end
end