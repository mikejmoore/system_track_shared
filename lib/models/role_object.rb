require_relative "./model_logic/role_logic"
require 'ostruct'


class RoleObject < OpenStruct
  include RoleLogic
end