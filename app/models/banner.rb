# There should be a publish and unpublish dates added later
# Much of the banners is an adaptation of the paul_revere gem. (
# https://github.com/thoughtbot/paul_revere)
class Banner < ApplicationRecord
  scope :visible,         -> { where(visible: true) }
  scope :invisible,       -> { where(visible: false) }
  scope :by_created_at,   -> { order(created_at: :desc) }

end
