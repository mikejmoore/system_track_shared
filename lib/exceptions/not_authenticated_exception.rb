module SystemTrack

  class NotAuthenticatedException < Exception
  
    def initialize(message = "Not signed in")
      super(message)
    end
  
  end
end