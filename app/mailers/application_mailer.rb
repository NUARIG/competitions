# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # TODO: set per environment email
  default from: COMPETITIONS_CONFIG[:mailer][:mailer_address]
  layout 'mailer'
  helper :users
end
