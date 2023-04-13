module GrantSubmissions
  module Submissions
    class ExportController < GrantSubmissions::SubmissionsController

      def index
        @grant      = Grant.kept.friendly.with_administrators.find(params[:grant_id])

        if Pundit.policy(current_user, @grant).show?
          @questions  = @grant.questions
          @submissions = policy_scope(GrantSubmission::Submission.with_responses, policy_scope_class: GrantSubmission::SubmissionPolicy::Scope)
        else
          skip_policy_scope
          flash[:alert] = I18n.t('pundit.default')
          redirect_to root_path
        end

        respond_to do |format|
          # trim grant name so the exported file name is max 205 chars
          format.xlsx { response.headers['Content-Disposition'] = "attachment; filename=submissions-#{@grant.name.gsub(/\W/,'')[0,178]}-#{DateTime.now.strftime('%Y_%m%d')}.xlsx" }
        end
      end
    end
  end
end
