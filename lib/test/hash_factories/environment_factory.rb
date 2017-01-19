require_relative "../../models/model_logic/machine_logic"

def environment_hash(account_id)
  code = RandomWord.adjs.next
  
  env = {
          account_id: account_id,
          code: code, 
          name: "#{code.titleize} Environment", 
          category: ["test", "production"].sample
        }
  return env
end