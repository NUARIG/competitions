# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # TODO: set per environment email
  default from: "no-reply-competitions-cd2h@#{Rails.application.credentials.dig(Rails.env.to_sym, :app_domain)}"
  layout 'mailer'
  helper :users
end
