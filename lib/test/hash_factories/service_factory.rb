require_relative "../../models/model_logic/network_logic"
def service_hash(account_id)
  code = RandomWord.adjs.next
  service = {
              code: code,
              name: "#{code.titleize} Service", 
              description: "#{code} Service is a very important service"
            }
  return service
end