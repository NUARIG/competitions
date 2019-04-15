module Grants
  class HomeDecorator < Draper::Decorator
    delegate_all

    def initialize(*args)
      super(GrantDecorator.new(*args))
    end

    def submission_period
      "#{submission_open_date} - #{submission_close_date}"
    end
  end
end
