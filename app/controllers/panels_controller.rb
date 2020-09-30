class PanelsController < ApplicationController
  before_action :set_grant_and_panel

  def show
    authorize @panel
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
      flash[:alert] = @panel.errors.full_messages
      render :edit
    end
  end

  private

  def set_grant_and_panel
    @grant = Grant.kept.friendly.find(params[:grant_id])
    @panel = @grant.panel
  end

  def panel_params
    params.require(:panel).permit(
        :start_datetime,
        :end_datetime,
        :instructions,
        :meeting_link,
        :meeting_location
    )
  end
end
