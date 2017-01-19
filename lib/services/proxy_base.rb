require_relative "../exceptions/credentials_expired_exception"
require_relative "../exceptions/bad_credentials_exception"
require_relative "./system_configuration"

module SystemTrack

  class ProxyBase
  
    def initialize
      @service_connection = nil
    end
  
    def connection(address)
      if (!@service_connection)
        @service_connection = Faraday.new(:url => "#{address}") do |faraday|
          faraday.request  :url_encoded             # form-encode POST params
          #faraday.response :logger                  # log requests to STDOUT
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end
      end
      return @service_connection
    end

    def expect_http_200(response)
      raise "Bad http response" if (response.status != 200)
    end
  end
end