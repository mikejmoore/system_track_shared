module SystemTrack

  class NotAuthorizedException < Exception
  
    def initialize(message = "Not authorized")
      super(message)
    end
  
  end
end
  