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

  def get_login_url_by_email_address(email)
    User.is_saml_email_address?(email: email) ? login_index_url : new_registered_user_registration_url
  end
end
