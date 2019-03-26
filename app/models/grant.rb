# frozen_string_literal: true

class Grant < ApplicationRecord
  attr_accessor :default_set

  has_paper_trail versions: { class_name: 'PaperTrail::GrantVersion' }

  belongs_to  :organization
  has_many    :questions, dependent: :destroy
  has_many    :grant_users
  has_many    :users, through: :grant_users

  accepts_nested_attributes_for :questions

  enum state: {
    demo:     'demo',
    draft:    'draft',
    complete: 'complete'
  }

  validates_presence_of :name
  validates_presence_of :submission_open_date
  validates_presence_of :submission_close_date
  validates_presence_of :publish_date

  validates_date :publish_date,
                 on: :create,
                 on_or_after: :today,
                 on_or_after_message: 'cannot be earlier than today.'
  validates_date :submission_open_date,
                 on: %i[create update],
                 on_or_after: :publish_date,
                 on_or_after_message: 'cannot be earlier than the publish date.'
  validates_date :submission_close_date,
                 after: :submission_open_date,
                 after_message: 'must be after the opening date for submissions.'
  validates_date :review_open_date,
                 after: :submission_open_date,
                 after_message: 'must be after the submission open date.'
  validates_date :review_close_date,
                 after: :review_open_date,
                 after_message: 'must be after the review opening date.'
  validates_date :panel_date,
                 after: :submission_close_date,
                 after_message: 'must be after the submission close date.',
                 if: :panel_date?

  validates :name, uniqueness: true
  validates :short_name,
            presence: true, if: -> { name.present? && name.length > 10 },
            length: { minimum: 3, maximum: 10 },
            uniqueness: true

  validates :max_reviewers_per_proposal,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 },
            if: :max_reviewers_per_proposal?
  validates :max_proposals_per_reviewer,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 },
            if: :max_proposals_per_reviewer?

  validate :valid_default_set, on: :create

  scope :by_publish_date, -> { order(publish_date: :asc) }
  scope :with_organization,  -> { joins(:organization) }
  scope :with_questions,     -> { includes :questions }

  # def save_questions_and_role(user:)
  #   return
  #   DefaultSet.find(default_set).questions.ids.each do |q_id|
  #     new_question = Question.find(q_id).dup
  #     new_question.update_attributes(grant_id: id)
  #     ConstraintQuestion.where(question_id: q_id).each do |constraint_question|
  #       constraint_question.dup.update_attributes(question_id: new_question.id)
  #     end
  #   end
  #   GrantUser.create!(grant: self, user: user, grant_role: 'admin')
  # end

  def valid_default_set
    errors.add(:base, 'Please choose a default question set') unless DefaultSet.where(id: default_set).exists?
  end
end
