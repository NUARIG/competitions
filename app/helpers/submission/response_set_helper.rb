module Submission::ResponseSetHelper
  # BEGIN form_base_helper methods
  # check permission to update or qa patient form before showing the link
  def link_to_update_or_qa_form(*args)
    if allow_update_or_qa?
      link_to *args
    end
  end

  def link_to_add_or_delete_form(*args)
    if allow_update?
      link_to *args
    end
  end

  #TODO: Create polices
  def allow_update_or_qa?
    true
    #Pundit.policy(current_user, form_owner).update_or_qa?
  end

  def allow_update?
    true
    #Pundit.policy(current_user, form_owner).update?
  end
  # /END form_base_helper methods
end
