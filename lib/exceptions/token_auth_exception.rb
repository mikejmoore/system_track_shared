module SystemTrack
  class TokenAuthException < RuntimeError

    def initialize(message)
      super(message)
    end

  end
end