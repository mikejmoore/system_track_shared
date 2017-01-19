require_relative "./model_logic/user_logic"
require_relative "./role_object"
require 'ostruct'

class UserObject < OpenStruct
  include UserLogic
  
  def initialize(hash)
    super(hash)
    self.roles = []
   
    hash['roles'].each do |role|
      self.roles << RoleObject.new(role)
    end
  end
end