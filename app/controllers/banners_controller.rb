class BannersController < ApplicationController
  before_action :set_banner,    except: %i[index new create]

  def index
    @q = policy_scope(Banner)
    if @q.present?
      @q = @q.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @pagy, @banners = pagy(@q.result, i18n_key: 'activerecord.models.banner')
    else
      redirect_to root_path
    end
  end

  def new
    @banner = Banner.new
    authorize @banner
  end

  def create
    @banner = Banner.new(banner_params)
    authorize @banner
    if @banner.save
      # TODO: Confirm messages the user should see
      flash[:notice]  = 'Banner saved.'
      flash[:warning] = 'This banner will continue to be visible until that setting is changed or it is deleted.'
      redirect_to banners_path
    else
      flash.now[:alert] = @banner.errors.full_messages
      render :new
    end
  end

  def edit
    authorize @banner
  end

  def update
    authorize @banner
    if @banner.update(banner_params)
      flash[:notice] = 'Banner was successfully updated.'
      redirect_to banners_path
    else
      flash.now[:alert] = @banner.errors.full_messages
      render :edit
    end
  end

  def destroy
    authorize @banner
    if @banner.nil?
      flash[:alert] = 'Banner could not be found.'
    else
      if @banner.destroy
        flash[:success] = 'The banner has been deleted.'
      else
        flash[:alert] = 'Unable to delete this banner.'
      end
    end
    redirect_to banners_path
  end

  private

  def banner_params
    params.require(:banner).permit(
      :body,
      :visible
      )
  end

  def set_banner
    @banner = Banner.find(params[:id])
  end

end
