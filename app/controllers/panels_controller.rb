class PanelsController < ApplicationController
  before_action :set_grant
  before_action :set_panel

  def show
    authorize @panel
    @user_grant_role = current_user.get_role_by_grant(grant: @grant)

    @q                  = @grant.submissions.kept.reviewed.with_applicants.ransack(params[:q])
    @q.sorts            = 'average_overall_impact_score asc' if @q.sorts.empty?
    @pagy, @submissions = pagy_array(@q.result.to_a.uniq, i18n_key: 'activerecord.models.grant_submission_submission')
    render :show
  end

  def edit
    authorize @grant, :grant_editor_access?
    render :edit
  end

  def update
    authorize @grant, :grant_editor_access?
    if @panel.update(panel_params)
      flash[:notice] = 'Panel information successfully updated.'
      redirect_to edit_grant_panel_path(@grant)
    else
      flash.now[:alert] = @panel.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_grant
    @grant = Grant.kept.friendly.with_panel.find(params[:grant_id])
  end

  def set_panel
    @panel = @grant.panel
  end

  def panel_params
    params.require(:panel).permit(:start_datetime,
                                  :end_datetime,
                                  :instructions,
                                  :meeting_link,
                                  :meeting_location,
                                  :show_review_comments)
  end
end
