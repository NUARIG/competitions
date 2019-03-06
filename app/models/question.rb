class Question < ApplicationRecord
  self.inheritance_column = 'answer_type'

  has_paper_trail versions: { class_name: 'PaperTrail::QuestionVersion' }

  belongs_to :grant

  has_many :constraint_questions
  has_many :constraints, through: :constraint_questions
  accepts_nested_attributes_for :constraint_questions

  has_many :default_sets_questions
  has_many :default_sets, through: :default_sets_questions

  validates_presence_of :name
  validates_length_of :name, minimum: 3, maximum: 255

  scope :with_grant, -> { includes :grant }
  scope :with_constraints, -> { includes :constraints }
  scope :with_constraint_questions, -> { includes :constraint_questions }
  scope :with_constraints_and_constraint_questions, -> { with_constraints.with_constraint_questions }
end
