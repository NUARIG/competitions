# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # TODO: set per environment email
  default from: 'no-reply@environment-specific-domain.com'
  layout 'mailer'
  helper :users
end
