class Criterion < ApplicationRecord
  attr_accessor :_destroy

  DEFAULT_CRITERIA = %w[Significance
                        Investigator(s)
                        Innovation
                        Approach
                        Environment].freeze

  belongs_to :grant,            inverse_of: :criteria
  has_many   :criteria_reviews
  # TODO: will we need this?
  # has_many   :reviews,          through: :criterion_reviews

  validates_presence_of :name
  validates :name, uniqueness: { scope: :grant }
end
