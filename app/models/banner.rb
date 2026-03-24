class Banner < ApplicationRecord
  after_commit :clear_cache

  has_paper_trail versions: { class_name: 'PaperTrail::BannerVersion' }

  scope :visible,         -> { where(visible: true) }
  scope :invisible,       -> { where(visible: false) }
  scope :by_created_at,   -> { order(created_at: :desc) }

  validates_presence_of   :body

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at updated_at visible]
  end

  def self.ransackable_associations(auth_object = nil); end

  def clear_cache
    Rails.cache.clear('current_banners') unless Rails.cache.read('current_banners').nil?
  end
end
