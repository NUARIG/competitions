# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # TODO: set per environment email
  default from: Rails.application.credentials.dig(Rails.env.to_sym, :mailer_address)
  layout 'mailer'
  helper :users
end
