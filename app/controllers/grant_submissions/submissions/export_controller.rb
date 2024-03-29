module GrantSubmissions
  module Submissions
    class ExportController < GrantSubmissions::SubmissionsController

      def index
        @grant = Grant.includes(form: [sections: :questions]).kept.friendly.with_administrators.find(params[:grant_id])

        if Pundit.policy(current_user, @grant).show?
          # Get the questions in order of the submission form.
          @questions   = @grant.sections.order(:display_order).flat_map{ |section| section.questions.order(:display_order) }
          @submissions = policy_scope(GrantSubmission::Submission.with_responses, policy_scope_class: GrantSubmission::SubmissionPolicy::Scope)
        else
          skip_policy_scope
          flash[:alert] = I18n.t('pundit.default')
          redirect_to root_path
        end

        respond_to do |format|
          # truncate grant name so the exported file name is max 205 chars
          format.xlsx { response.headers['Content-Disposition'] = "attachment; filename=submissions-#{@grant.name.gsub(/\W/,'')[0,178]}-#{DateTime.now.strftime('%Y_%m%d')}.xlsx" }
        end
      rescue ActiveRecord::RecordNotFound
        skip_policy_scope
        flash[:alert] = 'Grant not found.'
        redirect_back fallback_location: root_path
      end
    end
  end
end
