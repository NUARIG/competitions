# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: COMPETITIONS_CONFIG[:mailer][:mailer_address]
  layout 'mailer'
  helper :users
end
