require 'csv'
require 'date'

namespace :reports do
  desc 'creates a csv of all submissions for a grant'
  task :grant_submissions, [:grant] => [:environment] do |t, args|
    grant = Grant.where(name: args[:grant]).first
    submissions = grant.submissions

    csv_file = "#{Rails.root}/tmp/#{grant}_submissions_#{Time.now.strftime("%Y-%m-%d-%H-%M-%S")}.csv"
    puts "Writing submissions to file: #{csv_file}"

    column_headers = [ "applicant last name", "applicant first name", "applicant email", "project title"]
    questions = []
    submissions.first.responses.each { |response| questions << response.question.text }
    column_headers.concat questions

    CSV.open(csv_file, "w") do |csv|
      csv << column_headers

      submissions.each do |submission|
        applicant = submission.applicant

        submission_fields = [applicant.last_name, applicant.first_name, applicant.email, submission.title]
        submission_fields.concat submission.responses.map(&:response_value)

        csv << submission_fields
        STDOUT.flush
      end
    end
  end
end
