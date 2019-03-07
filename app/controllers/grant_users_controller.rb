class GrantUsersController < ApplicationController
	before_action :set_grant
	before_action :set_grant_user, only: %i[edit update destroy]

	# GET /grants/:study_id/grant_users
	def index
		@grant_users = @grant.grant_users.all
		authorize @grant_users
	end

	# GET /grants/:study_id/grant_user/new
  def new
		@users = unassigned_grant_users_by_organization
    @grant_user = GrantUser.new(grant: @grant)
    authorize @grant_user
  end

  def edit
    @user = @grant_user.user
    @role = @grant_user.grant_role
    authorize @grant_user
  end

  # POST /questions
  # POST /questions.json
  def create
    @grant_user = GrantUser.new(grant_id: @grant.id, user_id: params[:grant_user][:user], grant_role: params[:grant_user][:grant_role])
    authorize @grant_user
    respond_to do |format|
      if @grant_user.save
        flash[:success] = 'Grant user was successfully added.'
        format.html { redirect_to grant_grant_users_path(@grant) }
        format.json { render :show, status: :created, location: @grant_user }
      else
      	@users = unassigned_grant_users_by_organization
      	flash[:alert] = @grant_user.errors
        format.html { render :new }
        format.json { render json: @grant_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
  	authorize @grant_user
    respond_to do |format|
      if @grant_user.update(grant_user_params)
        flash[:success] = 'Grant user updated.'
        format.html { redirect_to grant_grant_users_path(@grant) }
        format.json { render :show, status: :ok, location: @grant_user }
      else
      	@emails = unassigned_grant_users_by_organization.pluck(:email)
      	flash[:alert] = @grant_user.errors
        format.html { render :edit }
        format.json { render json: @grant_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
  	authorize @grant_user
    @grant_user.destroy
    respond_to do |format|
      flash[:success] = 'Grant user was successfully destroyed.'
      format.html { redirect_to grant_grant_users_path }
      format.json { head :no_content }
    end
  end

  private

    def set_grant
      @grant = Grant.find(params[:grant_id])
    end

    def set_grant_user
    	@grant_user = GrantUser.find(params[:id])
    end

    def unassigned_grant_users_by_organization
    	User.left_outer_joins(:grant_users)
          .where("grant_users.grant_role is null")
          .where(organization: @grant.organization)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grant_user_params
      params.require(:grant_user).permit(
        :grant,
        :user,
        :grant_role)
    end
end
