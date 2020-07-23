# frozen_string_literal: true

class ReminderMailer < ApplicationMailer
  def grant_reviews_reminder(grant:, reviewer:, incomplete_reviews: )
    @grant              = grant
    @reviewer           = reviewer
    @incomplete_reviews = incomplete_reviews

    mail(to: reviewer.email, subject: I18n.t('mailers.reminder.grant_reviews.subject', grant_name: grant.name))
  end
end

