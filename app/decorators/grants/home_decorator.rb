module Grants
  class HomeDecorator < Draper::Decorator
    delegate_all

    def initialize(*args)
      super(GrantDecorator.new(*args))
    end

    def submission_period
      "#{submission_open_date} - #{submission_close_date}"
    end

    def edit_menu_link
      super if h.user_signed_in?
    end

    def view_submissions_menu_link
      super if h.user_signed_in?
    end
  end
end
