module SystemTrack

  class CredentialsExpiredException < Exception
  
    def initialize(message = "Credentials Expired")
      super(message)
    end
  
  end
end