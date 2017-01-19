module SystemTrack

  class CsrfValidationException < Exception
    def initialize(message = "CSRF Validation Failed")
      super(message)
    end
  end
end