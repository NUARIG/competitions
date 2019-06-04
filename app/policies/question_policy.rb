# frozen_string_literal: true

class QuestionPolicy < GrantPolicy
  def index?
    grant_viewer_access?
  end

  def show?
    index?
  end

  def create?
    grant_editor_access?
  end

  def new?
    create?
  end

  private

  def question
    record
  end

  def grant
    clean_record_from_collection.grant
  end

  def confirm_organization
    user.present? &&
      clean_record_from_collection.grant.organization == user.organization
  end
end
