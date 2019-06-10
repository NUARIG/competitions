# frozen_string_literal: true

module GrantsHelper

  def grant_can_be_deleted?(grant)
    grant.submissions.none? && grant.state.in?(Grant::SOFT_DELETABLE_STATES)
  end
end
