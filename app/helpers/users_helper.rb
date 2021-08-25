# frozen_string_literal: true

module UsersHelper
  def full_name(user)
    [user.first_name, user.last_name].reject { |n| n.nil? or n.blank? }.join(' ')
  end

  def sortable_full_name(user)
    [user.last_name, user.first_name].reject { |n| n.nil? or n.blank? }.join(', ')
  end

  def full_name_list(users)
    users.map{ |user| full_name(user) }.to_sentence
  end

  def sortable_full_name_list(users)
    users.map{ |user| full_name(user) }.to_sentence(words_connector: '; ')
  end
end
