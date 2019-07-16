# frozen_string_literal: true

module UsersHelper
  def full_name(user)
    "#{user.first_name} #{user.last_name}"
  end

  def sortable_full_name(user)
    "#{user.last_name}, #{user.first_name}"
  end

end
