class Question < ApplicationRecord
  has_paper_trail versions: { class_name: 'PaperTrail::QuestionVersion' }

  belongs_to :field
  belongs_to :grant

  validates_presence_of :name

  validates_length_of :name, minimum: 3, maximum: 255

  scope :with_grant, -> { includes :grant }
end
