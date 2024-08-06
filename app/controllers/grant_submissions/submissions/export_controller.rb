module GrantSubmissions
  module Submissions
    class ExportController < GrantSubmissions::SubmissionsController
      def index
        @grant = Grant.includes(form: [sections: :questions])
                      .kept
                      .friendly
                      .with_administrators
                      .find(params[:grant_id])

        if Pundit.policy(current_user, @grant).edit?
          populate_questions
          populate_submissions
        else
          skip_policy_scope
          flash[:alert] = I18n.t('pundit.default')
          redirect_to root_path
        end

        respond_to do |format|
          # truncate grant name so the exported file name is max 205 chars
          format.xlsx do
            response.headers['Content-Disposition'] =
              "attachment; filename=submissions-#{download_file_name}.xlsx"
          end
        end
      rescue ActiveRecord::RecordNotFound
        skip_policy_scope
        flash[:alert] = 'Grant not found.'
        redirect_back fallback_location: root_path
      end

      private

      def populate_questions
        # Get the questions in order of the submission form.
        @questions = @grant.sections.order(:display_order).flat_map do |section|
          section.questions.order(:display_order)
        end
      end

      def populate_submissions
        @submissions = GrantSubmission::Submission.kept
                                                  .includes(:reviews, :applicants, :responses)
                                                  .where(grant: @grant)
      end

      def download_file_name
        "#{@grant.name.gsub(/\W/, '')[0, 178]}-#{DateTime.now.strftime('%Y_%m%d')}"
      end
    end
  end
end
