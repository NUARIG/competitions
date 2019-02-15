class Question < ApplicationRecord
  belongs_to :field
  belongs_to :grant

  validates_presence_of :name

  validates_length_of :name, minimum: 3, maximum: 255

  scope :with_grant, -> { includes :grant }
end
