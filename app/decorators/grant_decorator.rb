# frozen_string_literal: true

class GrantDecorator < Draper::Decorator
  delegate_all

  # TODO: add context for user roles: https://github.com/drapergem/draper#adding-context

  def name_length_class
    case
    when object.name.length > 85
      'long'
    when object.name.length > 50
      'medium'
    end
  end

  def show_menu_link
    h.content_tag(:li, show_link, class: 'show-link', id: "show-#{h.dom_id(object)}")
  end

  def edit_menu_link
    h.content_tag(:li, edit_link, class: 'edit-link', id: "edit-#{h.dom_id(object)}") if h.policy(object).edit?
  end

  private

  def show_link
    h.link_to 'RFA', h.grant_path(object), id: "show-#{h.dom_id(object)}-link"
  end

  def edit_link
    h.link_to 'Edit', h.edit_grant_path(object), id: "edit-#{h.dom_id(object)}-link"
  end
end
