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

  # enum answer_type: {
  #   boolean:  'BooleanQuestion',
  #   integer:  'IntegerQuestion',
  #   float:    'FloatQuestion',
  #   string:   'StringQuestion',
  #   text:     'TextQuestion',
  #   document: 'DocumentQuestion'
  # }, _prefix: true

  scope :with_grant, -> { includes :grant }
  scope :with_constraints, -> { includes :constraints }
  scope :with_constraints_and_constraint_questions,
          -> { includes :constraints, :constraint_questions }
end
