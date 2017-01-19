if (ENV['RAILS_ENV'] == 'development')
  require 'byebug'
end

# Dir.glob("../services/**/*.rb").each { |f|
#   require f
# }
#
#
Dir.glob("../models/**/*.rb").each { |f|
  require f
}

Dir.glob("../exceptions/**/*.rb").each { |f|
  require f
}

module SystemTrack
  module ApplicationControllerModule
    protected
    
    def required_parameter(param_symbol)
      param_value = params[param_symbol]
      raise "Missing require parameter: :#{param_symbol}" if (param_value == nil)
      return param_value
    end
  
    def current_user
      return find_user_from_session
    end
  
    def find_user_from_session
      if (session[:user])
        @current_user = UserObject.new(session[:user])
        if (@current_user == nil) || (@current_user[:credentials] == nil)
          raise "User not signed in"
        end
        begin
          Rails.logger.info "AUTH - FIND USER: SESSION: #{session.id}"
          UsersProxy.new.validate_token(@current_user[:credentials])
        rescue
          add_flash_message(:warning, "User sign in expired (#{@current_user['email']})")
          session[:user] = nil
          @current_user = nil
        end
      else
        @current_user = nil
      end
      return @current_user
    end
  
  
    def find_user
      @user = nil
      if (params[:credentials]) && (params[:credentials][:uid])
        credentials = params[:credentials]
        authenticate_token
        if (credentials)
          user_hash = UsersProxy.new.find_user({credentials: credentials}, credentials[:uid]) 
          @user = UserObject.new(user_hash)
          @current_user = @user
          @user.credentials = credentials
          Rails.logger.info "Current user: #{@user.email}"
        end
      end
    end
  
    def sign_on_if_credentials
      add_flash_message(:warning, "Test Flash Message")
      
      email = params[:email]
      password = params[:password]
      if (email != nil) && (password != nil)
        UsersProxy.new.sign_in(session, email, password)
        find_user_from_session
        Rails.logger.info "After sign in, current user = #{@current_user}"
      end
    end
  
    def not_authorized
      render :text => "Not authorized", :status => 401
    end

    def not_found
      return api_error(status: 404, errors: 'Not found')
    end

    def token_auth_error
      render :text => "User authorization with token failed", :status => 401
    end


    def destroy_session
      request.session_options[:skip] = true
    end
  
    def authenticate_token
      if (params[:credentials])
        UsersProxy.new.validate_token(params[:credentials])
      end
    end
  
    def hash_to_param_string(params)
      str = ""
      params.keys.each do |param_name|
        str += "#{param_name}=#{params[param_name]}&"
      end
      return str
    end
  
    def validate_credentials
      # email = params[:email]
      # password = params[:password]
      # if (email != nil) && (password != nil)
      #   Rails.logger.info "User is attempting new login, old credentials don't matter"
      # else
        Rails.logger.info "AUTH - FIND USER: SESSION: #{session.id}"
    
        credentials = session['credentials']
        if (credentials)
          UsersProxy.new.validate_token(credentials)
        else
          session[:user] = nil
        end
  #    end
    end

    def add_flash_message(severity, message)
      session[:flash_messages] = {} if session[:flash_messages] == nil
      session[:flash_messages][severity] = [] if session[:flash_messages][severity] == nil
      session[:flash_messages][severity] << message
    end

    def api_exception_handler(exception)
      if (exception.class == SystemTrack::BadCredentialsException)
        render text: "Bad credentials", status: 401
      elsif (exception.class == CredentialsExpiredException)
        render text: "Credentials expired", status: 401
      else
        message = []
        message << "#{exception.class} - #{exception.message[0..50]}"
        
        Rails.logger.error "#{exception.class} - #{exception.message}"
        # puts "#{exception.class} - #{exception.message}"
        
        exception.backtrace.each do |line|
          message << line[0..200]
          Rails.logger.error line[0..200]
          #puts line[0..200]
        end

        render text: {message: "An error occurred"}.to_json, :status => 500
      end
    end
  
  end
end