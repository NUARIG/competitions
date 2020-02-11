require 'csv'
require 'date'

# e.g. rake reports:grant_submissions["New Rose"]
namespace :reports do
  desc 'creates a csv of all submissions for a grant'
  task :grant_submissions, [:grant] => [:environment] do |t, args|
    grant = Grant.find(args[:grant])
    submissions = grant.submissions

    csv_file = "#{Rails.root}/tmp/#{grant.name.parameterize}_submissions_#{Time.now.strftime("%Y-%m-%d-%H-%M-%S")}.csv"
    puts "Writing submissions to file: #{csv_file}"

    questions = grant.questions
    question_ids = questions.map(&:id)
    questions_texts = questions.map(&:text)

    column_headers = [ "applicant last name", "applicant first name", "applicant email", "project title"]
    column_headers.concat questions_texts

    CSV.open(csv_file, "w") do |csv|
      csv << column_headers

      submissions.each do |submission|
        applicant = submission.applicant

        submission_fields = [applicant.last_name, applicant.first_name, applicant.email, submission.title]

        ordered_responses = submission.responses.sort_by { |response| question_ids.index response.grant_submission_question_id}
        submission_fields.concat ordered_responses.map(&:response_value)

        csv << submission_fields
        STDOUT.flush
      end
    end
  end
end
