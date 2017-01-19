#module UserHashFactory 
  def unregistered_user(account_id = nil)
    hash = {
      first_name: RandomWord.nouns.next,
      last_name: RandomWord.nouns.next,
      password: "secret123"
    }
    hash[:email] = "#{hash[:first_name]}.#{hash[:last_name]}@corp.com"
    hash[:account_id] = account_id if (account_id != nil)
    return hash
  end
  #end