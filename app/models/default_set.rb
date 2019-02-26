class DefaultSet < ApplicationRecord
  has_many :default_set_questions
  has_many :questions, through: :default_set_questions

  validates :name, presence: true, uniqueness: true
end
