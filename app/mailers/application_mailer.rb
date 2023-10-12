# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  prepend_view_path "app/views/mailers"

  default from: COMPETITIONS_CONFIG[:mailer][:email]

  layout 'mailer'

  helper UsersHelper
  helper GrantSubmissions::SubmissionsHelper
end
