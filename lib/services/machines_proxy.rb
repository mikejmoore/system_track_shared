require_relative "./proxy_base"
require_relative "../utils/ip_utils"

module SystemTrack
  class MachinesProxy < ProxyBase

    def initialize
      @cache = {}
    end
  
    def retrieve_from_cache(key)
      if (@cache[key])
        expires = @cache[key][:expires]
        if (expires > Time.now)
          @cache[key] = nil
        else
          return @cache[key][:data]
        end
      end
      return nil
    end

    def store_in_cache(key, data, expiration_time)
      @cache[key] = {data: data, expires: expiration_time}
    end
  
    def clear_cache(key)
      @cache[key] = nil
    end
  
    def service_connection
      address = SystemConfiguration.new.address_for(:machine)
      return connection(address)
    end

    def save_machine(session, machine)
      credentials = session[:credentials]
      response = service_connection.post "/api/v1/machines/save", {credentials: credentials, machine: machine}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
    end
    
    def save_machine_network_card(session, machine_id, network_card)
      credentials = session[:credentials]
      response = service_connection.post "/api/v1/machines/save_network_card", {credentials: credentials, 
        machine_id: machine_id, network_card: network_card}
        machine = JSON.parse(response.body)
      return machine
    end
    
    def delete_machine_network_card(session, network_card_id)
      credentials = session[:credentials]
      response = service_connection.delete "/api/v1/machines/delete_network_card", 
       {credentials: credentials, network_card_id: network_card_id}
      
      machine = JSON.parse(response.body)
      return machine
    end
    
    
    def machines_in_network(session, network_id, account_id = nil)
      machines = machine_list(session, account_id)
      machines_in_network = []
      machines.each do |machine|
        if (machine['network_id'] == network_id)
          machines_in_network << machine 
        end
      end
      return machines_in_network
    end
    
    def networks_add_machines(session, account_id = nil)
      unknown_network = {'id' => 0, 'name' => "Unknown", 'code' => "unknown", 'address' => "0.0.0.0"}
      networks = network_list(session, account_id)
      networks << unknown_network
      networks.each { |n|
        n['machines'] = []
      }
      machines = machine_list(session, account_id)
      machines.each do |m|
        network = networks.find {|n| n['id'] == m['network_id']}
        network = unknown_network if (network == nil)
        network['machines'] << m
      end
      networks.each do |n|
        n['machines'].sort! {|a, b|
          padded_ip(a['ip_address']) <=> padded_ip(b['ip_address'])
        }
      end
      return networks
    end


    def toggle_network_environment(session, network_id, environment_id)
      credentials = session[:credentials]
      response = service_connection.post "/api/v1/machines/toggle_network_environment", {credentials: credentials, machine_id: machine_id, service_id: service_id, environment_id: environment_id}
      expect_http_200(response)
      json = JSON.parse(response.body)
      return json['env_on']
    end  

  
    def toggle_service_for_machine(session, machine_id, service_id, environment_id)
      credentials = session[:credentials]
      response = service_connection.post "/api/v1/machines/toggle_service", {credentials: credentials, machine_id: machine_id, service_id: service_id, environment_id: environment_id}
      expect_http_200(response)
      json = JSON.parse(response.body)
      return json['service_on']
    end  
  
    def machine_list(session, account_id = nil)
      account_id = session[:user]["account_id"] if (account_id == nil)
      credentials = session[:credentials]
      response = service_connection.get "/api/v1/machines/index", {credentials: credentials, account_id: account_id}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
    end
    
    def find_machine_with_code(session, machine_code, account_id = nil)
      all_machines = machine_list(session, account_id)
      all_machines.each do |machine|
        return machine if (machine['code'] == machine_code)
      end
      return nil
    end

    def find_machine_with_ip(session, account_id, ip_address)
      all_machines = machine_list(session, account_id)
      matches = all_machines.select do |m|
        result = false
        if (m['ip_address'] == ip_address)
          result = true
        else
          m['network_cards'].each do |nic|
            if (nic['ip_address'] == ip_address)
              result = true
              break
            end
          end
        end
        result
      end
      raise "Multiple machines have same ip address: #{ip_address}" if (matches.length > 1)
      raise "No machine has ip address: #{ip_address}" if (matches.length == 0)
      return matches.first
    end


    def machine(session, machine_id)
      credentials = session[:credentials]
      response = service_connection.get "/api/v1/machines/get", {credentials: credentials, machine_id: machine_id}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
    end

    def save_network(session, network)
      credentials = session[:credentials]
      clear_cache(:network_list)
      response = service_connection.post "/api/v1/networks/save", {credentials: credentials, network: network}
      return_json = JSON.parse(response.body)
    end
  
    def network_list(session, account_id = nil)
      account_id = session[:user]["account_id"] if (account_id == nil)
      return_json = retrieve_from_cache(:network_list)
      if (return_json == nil)
        credentials = session[:credentials]
        response = service_connection.get "/api/v1/networks/index", {credentials: credentials, account_id: account_id}
        expect_http_200(response)
        return_json = JSON.parse(response.body)
        store_in_cache(:network_list, return_json, Time.now + 24.hours)
      end
      return return_json
    end
    
    def find_network_with_code(session, code, account_id = nil)
      all = network_list(session, account_id)
      all.each do |network|
        return network if (network['code'] == code)
      end
      return nil
    end
    
  
    def network(session, network_id)
      credentials = session[:credentials]
      response = service_connection.get "/api/v1/networks/get", {credentials: credentials, network_id: network_id}
      expect_http_200(response)
      json = JSON.parse(response.body)
      return json
    end

    def network_status_list
      status_json = retrieve_from_cache(:network_status_list)
      if (status_json == nil) 
        response = service_connection.get "/api/v1/networks/status_list", {}
        expect_http_200(response)
        status_json = JSON.parse(response.body)
        store_in_cache(:network_status_list, status_json, Time.now + 24.hours)
      end
      return status_json
    end

    def save_service(session, service)
      credentials = session[:credentials]
      response = service_connection.post "/api/v1/services/save", {credentials: credentials, service: service}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
    end
    
    def environment_list(session, account_id = nil)
      account_id = session[:user]["account_id"] if (account_id == nil)
      credentials = session[:credentials]
      response = service_connection.get "/api/v1/environments/index", {credentials: credentials, account_id: account_id}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
      return return_json
    end
    

    def save_environment(session, environment)
      credentials = session[:credentials]
      response = service_connection.post "/api/v1/environments/save", {credentials: credentials, environment: environment}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
    end
    
    def delete_environment(session, environment_id)
      credentials = session[:credentials]
      response = service_connection.delete "/api/v1/environments/delete", {
            credentials: credentials, 
            environment_id: environment_id}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
      return return_json
    end
  
    def service_list(session, account_id = nil)
      account_id = session[:user]["account_id"] if (account_id == nil)
      credentials = session[:credentials]
      response = service_connection.get "/api/v1/services/index", {credentials: credentials, account_id: account_id}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
      return return_json
    end
    
    def find_service_with_code(session, code, account_id = nil)
      all = service_list(session, account_id)
      all.each do |service|
        return service if (service['code'] == code)
      end
      return nil
    end
    
  
    def service(session, id)
      credentials = session[:credentials]
      response = service_connection.get "/api/v1/services/get", {credentials: credentials, service_id: id}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
    end
  
    def attach_service_to_network(session, service_id, network_id)
    # put "/api/v1/services/add_to_network"
    # delete "/api/v1/services/remove_from_network"
      credentials = session[:credentials]
      response = service_connection.put "/api/v1/services/add_to_network", {credentials: credentials, service_id: service_id, network_id: network_id}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
    end
    
    def attach_service_to_environment(session, service_id, environment_id)
      credentials = session[:credentials]
      response = service_connection.put "/api/v1/environments/add_to_service", {credentials: credentials, service_id: service_id, environment_id: environment_id}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
    end
    
    def remove_service_from_environment(session, service_id, environment_id)
      credentials = session[:credentials]
      response = service_connection.put "/api/v1/environments/add_to_service", {credentials: credentials, service_id: service_id, environment_id: environment_id}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
    end

  
    def attach_service_to_machine(session, service_id, machine_id, card_ip_address, environment_id)
      credentials = session[:credentials]
      response = service_connection.put "/api/v1/services/add_to_machine", {credentials: credentials, service_id: service_id, machine_id: machine_id, ip_address: card_ip_address, environment_id: environment_id}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
    end
    
    def attach_environment_to_network(session, environment_id, network_id)
      credentials = session[:credentials]
      response = service_connection.put "/api/v1/environments/add_to_network", 
        { credentials: credentials, 
          network_id: network_id, 
          environment_id: environment_id}
      expect_http_200(response)
      return_json = JSON.parse(response.body)
    end
    
    def ansible_hosts(public_key_hash)
      response = service_connection.get "/api/v1/machines/ansible_hosts", {public_key_hash: public_key_hash}
      encrypted_hosts_file = response.body
    end
    
  end
end
