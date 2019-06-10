# frozen_string_literal: true

module GrantsHelper

  def display_delete_link?(grant)
    grant.submissions.none? && grant.state == 'draft'
  end
end
