require_relative "../../models/model_logic/network_logic"

def network_hash(account_id)
  code = RandomWord.adjs.next
  
  network = {
              code: code, 
              name: "#{code.titleize} Network", 
              address: "#{50 + rand(200)}.#{50 + rand(200)}.#{50 + rand(200)}.0", 
              mask: "255.255.255.0",
              account_id: account_id,
              activation_date: DateTime.now,#.strftime('%Y/%m/%d'),
              status:  'activated',
              price:  (10000 + rand(20000)) / 100.0
            }
  return network
end