class Criterion < ApplicationRecord
  has_paper_trail versions: { class_name: 'PaperTrail::CriterionVersion' },
                  meta:     { grant_id: :grant_id }

  DEFAULT_CRITERIA = %w[Significance
                        Investigator(s)
                        Innovation
                        Approach
                        Environment].freeze

  belongs_to :grant,            inverse_of: :criteria
  has_many   :criteria_reviews, dependent: :destroy

  validates_presence_of :name
  validates :name, uniqueness: { scope: :grant }
end
