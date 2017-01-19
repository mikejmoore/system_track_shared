require_relative "../../models/model_logic/machine_logic"

def machine_hash(account_id)
  code = RandomWord.adjs.next
  
  machine = {
              code: code, 
              name: "#{code.titleize} Machine", 
              ip_address: "#{50 + rand(200)}.#{50 + rand(200)}.#{50 + rand(200)}.#{50 + rand(200)}", 
              account_id: account_id,
              purchase_date: DateTime.now,   #.strftime('%Y/%m/%d'),
              activation_date: DateTime.now, #.strftime('%Y/%m/%d'),
              status:  :activated.to_s,
              price:  (10000 + rand(20000)) / 100.0,
              machine_tags: [{tag: RandomWord.adjs.next}, {tag: RandomWord.adjs.next}, {tag: RandomWord.adjs.next}],
              network_cards: [
                {ip_address: "#{50 + rand(200)}.#{50 + rand(200)}.#{50 + rand(200)}.#{50 + rand(200)}", 
                    mac_address: "34-43-35-#{rand(50)}-#{rand(50)}", interface: "eth1", ssh_service: true},
                {ip_address: "#{50 + rand(200)}.#{50 + rand(200)}.#{50 + rand(200)}.#{50 + rand(200)}", 
                    mac_address: "34-43-35-#{rand(50)}-#{rand(50)}", interface: "eth2", ssh_service: false},
                {ip_address: "#{50 + rand(200)}.#{50 + rand(200)}.#{50 + rand(200)}.#{50 + rand(200)}", 
                    mac_address: "34-43-35-#{rand(50)}-#{rand(50)}", interface: "eth3", ssh_service: false},
                {ip_address: "#{50 + rand(200)}.#{50 + rand(200)}.#{50 + rand(200)}.#{50 + rand(200)}", 
                    mac_address: "34-43-35-#{rand(50)}-#{rand(50)}", interface: "eth4", ssh_service: false}
              ]
            }
  return machine
end