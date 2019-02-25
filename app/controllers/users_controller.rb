class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
    authorize @users
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
      	# format.html { redirect_to user_path(@user), notice: 'User was successfully created.' }
       #  format.json { render :show, status: :created, location: @user }
        format.html { redirect_to users_path(@user), notice: 'User was successfully updated.' }
        format.json { render :index, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.with_organization.find(params[:id])
      authorize @user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:era_commons, :organization_role)
    end
end
