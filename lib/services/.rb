require_relative "./service_base"


class UserService < ServiceBase
  include Singleton
  
  
  def service_connection
    user_address = SystemConfiguration.instance.address_for(:user)
    return connection(user_address)
  end

  
  def sign_in(session, email, password)
    user = nil
    params = { 
      email: email,
      password: password
    }
    response = service_connection.post "/api/v1/auth/sign_in", params
    
    if (response.status == 200)
      credentials = credentials_from_response(response)
      user = JSON.parse(response.body)['data'].to_hash
      user[:credentials] = credentials
      session[:user] = user
      puts "Signed in: #{user}"
    else  
      puts "Sign in failed.  Response: #{response.status}  #{response.body}"
      session[:user] = nil
    end
    return user
  end
  
  def validate_token(user)
    if (user) && (user[:credentials])
      credentials = user[:credentials]
      response = service_connection.get "/api/v1/auth/validate_token", credentials
      if (response.status == 200)
      elsif (response.status == 401)
        raise CredentialsExpiredException.new
      else 
        raise "Unexpected exception validating token"
      end
    else
      raise "No credentials stored in session"
    end
    
  end
  
  def logoff(session)
    credentials = session[:user][:credentials]
    session[:user] = nil
    response = service_connection.delete "/api/v1/auth/sign_out", credentials
    if (response.status == 200)
    end
  end
  
  def register(session, user_params)
    user = nil
    connection = service_connection
    response = connection.post "/api/v1/users/self_register", user_params
    if (response.status == 200)
      # Login user
      user = UserService.instance.sign_in(session, user_params[:user][:email], user_params[:user][:password])
    else
      raise BadCredentialsException.new
    end
    return user
  end
  
  def find_user(credentials, uid)
    response = service_connection.get "/api/v1/users/find_by_uid", {credentials: credentials, uid: uid}
    user = JSON.parse(response.body)
    return user
  end
  
  
  private
  def credentials_from_response(response)
    uid = response.headers['uid']
    token = response.headers['access-token']
    client = response.headers['client']
    return {uid: uid, 'access-token' => token, client: client}
  end
  
end