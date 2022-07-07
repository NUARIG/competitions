module BannersHelper
  def visible_banners
    return Rails.cache.fetch('current_banners', expires_in: 10.minutes) do
              Banner.visible.by_created_at.all.to_a
            end
  end
end
