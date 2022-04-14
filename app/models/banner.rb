class Banner < ApplicationRecord
  has_paper_trail versions: { class_name: 'PaperTrail::BannerVersion' }

  scope :visible,         -> { where(visible: true) }
  scope :invisible,       -> { where(visible: false) }
  scope :by_created_at,   -> { order(created_at: :desc) }

  validates_presence_of   :body

# TURBO BANNER WORK
  # has_paper_trail versions: { class_name: 'PaperTrail::BannerVersion' }

  # scope :visible,         -> { where(visible: true) }
  # scope :invisible,       -> { where(visible: false) }
  # scope :by_created_at,   -> { order(created_at: :desc) }

  # validates_presence_of   :body

  # # broadcasts_to ->(banner) { :banners }, inserts_by: :prepend

  # # after_create_commit { broadcast_prehttps://blog.cloud66.com/content/images/size/w1000/2021/02/making-hotwire-and-devise-play-nicely.pngpend_to "banners" }
  # # after_update_commit { broadcast_replace_to "banners" }
  # # after_destroy_commit { broadcast_remove_to "banners" }

  # after_create_commit :create_banner_view

  # after_update_commit :update_banner_view
  # after_destroy_commit :destroy_banner_view

  # private
  # def create_banner_view
  #   broadcast_prepend_to "banners"
  #   # broadcast_replace_to "new_banner_form", partial: 'banners/banner_form', banner: Banner.new
  #   # broadcast_replace_to "format_flash_messages"

  # end

  # def update_banner_view
  #   broadcast_replace_to "banners"
  # end

  # def destroy_banner_view
  #   broadcast_remove_to "banners"
  # end
end