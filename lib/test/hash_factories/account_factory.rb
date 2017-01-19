  def account_hash
    hash = {
      name: RandomWord.nouns.next,
      code: RandomWord.nouns.next
    }
    return hash
  end
