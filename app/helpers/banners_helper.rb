module BannersHelper
  def visible_banners
    @visible_banners ||= Banner.visible.by_created_at
  end
end