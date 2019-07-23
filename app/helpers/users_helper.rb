# frozen_string_literal: true

module UsersHelper
  def full_name(user)
    [user.first_name.titleize, user.last_name.titleize].reject { |n| n.nil? or n.blank? }.join(' ')
  end

  def sortable_full_name(user)
    [user.last_name.titleize, user.first_name.titleize].reject { |n| n.nil? or n.blank? }.join(', ')
  end

end
