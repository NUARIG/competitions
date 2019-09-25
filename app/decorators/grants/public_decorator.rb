module Grants
  class PublicDecorator < Draper::Decorator
    delegate_all

    def initialize(*args)
      super(GrantDecorator.new(*args))
    end

    def edit_menu_link
      super if h.user_signed_in?
    end
  end
end
