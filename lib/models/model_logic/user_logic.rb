module UserLogic
  def is_super_user?
    return has_role?(RoleLogic::SUPER_USER_CODE)
  end
  
  def is_admin?
    return has_role?(RoleLogic::ACCOUNT_ADMIN_CODE)
  end
  
  def has_role?(role_code)
    roles.each do |role|
      return true if (role.code == role_code)
    end
    return false
  end
  
end