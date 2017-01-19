require_relative "./proxy_base"
require_relative "../models/user_object"
require 'faraday'


module SystemTrack
  class AccountsProxy < ProxyBase
    
    def service_connection
      user_address = SystemConfiguration.new.address_for(:user)
      return connection(user_address)
    end

    def account_list(session)
      credentials = session[:credentials]
      # Must be a super user.
      response = service_connection.get "/api/v1/accounts/list", {credentials: credentials}
      expect_http_200(response)
      accounts = JSON.parse(response.body)
      return accounts
    end
    
    def account(session, account_id = nil)
      if (account_id == nil)
        account_id = session['user']['account_id']
      end
      credentials = session[:credentials]
      response = service_connection.get "/api/v1/accounts/#{account_id}", {credentials: credentials}
      expect_http_200(response)
      account = JSON.parse(response.body)
      return account
    end
    

    def save(session, account)
      credentials = session[:credentials]
      response = service_connection.post "/api/v1/accounts/save", {credentials: credentials, account: account}
      expect_http_200(response)
      account = JSON.parse(response.body)
      return account
    end

  end
end