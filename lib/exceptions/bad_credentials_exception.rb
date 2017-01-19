module SystemTrack

  class BadCredentialsException < Exception
    def initialize(message = "Bad Credentials")
      super(message)
    end
  end
end