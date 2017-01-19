require_relative "./proxy_base"
require_relative "../models/user_object"
require 'faraday'


module SystemTrack
  class UsersProxy < ProxyBase

    def service_connection
      user_address = SystemConfiguration.new.address_for(:user)
      return connection(user_address)
    end

    def ping
      params = {}
      response = service_connection.get "/ping", params
      return (response.status == 200)
    end

    def sign_in(session, email, password)
      logoff(session)

      user = nil
      params = {
        email: email,
        password: password
      }
      response = service_connection.post "/api/v1/auth/sign_in", params

      if (response.status == 200)
        credentials = credentials_from_response(response)
        user = JSON.parse(response.body)['data'].to_hash
        session[:credentials] = credentials
        session[:user] = find_user({credentials: credentials}, user['email'])
        session[:user][:credentials] = credentials
        session['_csrf_token'] ||= SecureRandom.base64(32)
        Rails.logger.info "AUTH - LOGIN: #{credentials}"
        puts "Signed in: #{user}"
      else
        puts "Sign in failed.  Response: #{response.status}  #{response.body}"
        session[:user] = nil
        raise BadCredentialsException.new
      end
      return session[:user]
    end

    def validate_token(credentials_hash, context = "Unknown Context")
      Rails.logger.info "AUTH - VALIDATE: #{credentials_hash}"
      if (credentials_hash)
        params = {context: context}.merge(credentials_hash)
        response = service_connection.get "/api/v1/auth/validate_token", params
        if (response.status == 200)
        elsif (response.status == 401)
          Rails.logger.info "AUTH - VALIDATION (EXPIRED)"
          raise CredentialsExpiredException.new
        else
          Rails.logger.info "AUTH - VALIDATION (EXCEPTION)"
          raise "Unexpected exception validating token"
        end
      else
        raise NotAuthenticatedException.new
      end
    end

    def logoff(session)
      credentials = session[:credentials]
      Rails.logger.info "AUTH - LOGOFF: #{credentials}"
      session[:user] = nil
      response = service_connection.delete "/api/v1/auth/sign_out", credentials
    end

    def register(session, user_params)
      user = nil
      connection = service_connection
      response = connection.post "/api/v1/users/self_register", user_params
      expect_http_200(response)
      if (response.status == 200)
        # Login user
        user = self.sign_in(session, user_params[:user][:email], user_params[:user][:password])
      else
        raise BadCredentialsException.new
      end
      return user
    end

    def find_user(session, uid)
      credentials = session[:credentials]
      raise "Credentials not given" if (!credentials)
      raise "Credentials missing uid" if (!credentials[:uid])
      response = service_connection.get "/api/v1/users/find_by_uid", {credentials: credentials, uid: uid}
      expect_http_200(response)
      user = JSON.parse(response.body)
      return user
    end

    def account_users(session, account_id)
      credentials = session[:credentials]
      response = service_connection.get "/api/v1/users", {credentials: credentials, account_id: account_id}
      expect_http_200(response)
      user = JSON.parse(response.body)
      return user
    end


    def create_user(session, user)
      credentials = session[:credentials]

                        # user: {
                        #   account_id: account.id,
                        #   first_name: RandomWord.nouns.next,
                        #   last_name: RandomWord.nouns.next,
                        #   email: "#{RandomWord.nouns.next}@corp.com",
                        #   password: "secret123"
                        #   }}
      response = service_connection.post "/api/v1/users/save", {credentials: credentials, user: user}
      expect_http_200(response)
      user = JSON.parse(response.body)
      return user
    end

    def add_ssh_key(session, user_id, public_key, code)
      credentials = session[:credentials]

      ssh_key = {code: code, public_key: public_key}
      params = {user_id: user_id, credentials: credentials, ssh_key: ssh_key}

      response = service_connection.post "/api/v1/users/add_ssh_key", params
      expect_http_200(response)
      return JSON.parse(response.body)
    end

    def find_ssh_key(public_key_hash)
      params = {public_key_hash: public_key_hash}
      response = service_connection.get "/api/v1/users/find_ssh_key", params
      expect_http_200(response)
      return JSON.parse(response.body)
    end

    private
    def credentials_from_response(response)
      uid = response.headers['uid']
      token = response.headers['access-token']
      client = response.headers['client']
      return {uid: uid, 'access-token' => token, client: client}
    end

  end
end