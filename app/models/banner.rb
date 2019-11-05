class Banner < ApplicationRecord
  has_paper_trail versions: { class_name: 'PaperTrail::BannerVersion' }

  scope :visible,         -> { where(visible: true) }
  scope :invisible,       -> { where(visible: false) }
  scope :by_created_at,   -> { order(created_at: :desc) }

  validates_presence_of   :body
end
