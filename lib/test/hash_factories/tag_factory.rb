def tag_hash(object_type, account_id = nil)
  hash = {
    name: RandomWord.nouns.next,
    code: RandomWord.nouns.next.downcase,
    object_type: object_type
  }
  hash[:account_id] = account_id if (account_id != nil)
  return hash
end
