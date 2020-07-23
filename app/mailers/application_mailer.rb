# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(Rails.env.to_sym, :mailer_address)
  layout 'mailer'
  helper :users
end
