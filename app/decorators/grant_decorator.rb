# frozen_string_literal: true

class GrantDecorator < Draper::Decorator
  delegate_all

  def name_length_class
    case
    when object.name.length > 50
      'long'
    when object.name.length > 35
      'medium'
    end
  end

  def show_menu_link
    h.content_tag(:li, show_link, class: 'show-link', id: "show-#{h.dom_id(object)}")
  end

  def apply_menu_link
    h.content_tag(:li, apply_link, class: 'apply-link', id: "apply-#{h.dom_id(object)}") if can_apply?
  end

  def edit_menu_link
    h.content_tag(:li, edit_link, class: 'edit-link', id: "edit-#{h.dom_id(object)}") if h.user_signed_in? && h.policy(object).edit?
  end

  def view_submissions_menu_link
    h.content_tag(:li, view_submissions_link, class: "submissions-link", id: "submissions-#{h.dom_id(object)}") if h.user_signed_in? && h.policy(object).grant_viewer_access?
  end

  private

  def show_link
    h.link_to 'RFA', h.grant_path(object), id: "show-#{h.dom_id(object)}-link"
  end

  def apply_link
    h.link_to 'Apply Now', h.new_grant_submission_path(object), id: "apply-#{h.dom_id(object)}-link"
  end

  def edit_link
    h.link_to 'Edit', h.edit_grant_path(object), id: "edit-#{h.dom_id(object)}-link"
  end

  def view_submissions_link
    h.link_to 'View Submissions', h.grant_submissions_path(object), id: "submissions-#{h.dom_id(object)}-link"
  end

  def can_apply?
    # TODO: Rules for admins, draft, etc
    object.published? && accepting_submissions?
  end

  def accepting_submissions?
    Time.now.between?(object.submission_open_date, object.submission_close_date)
  end
end
