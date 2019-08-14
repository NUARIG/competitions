# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :omniauthable, :database_authenticatable, :registerable, :recoverable, :validatable:rememberable
  devise :saml_authenticatable, :trackable, :timeoutable

  has_many   :grant_permissions
  has_many   :editable_grants,        through: :grant_permissions,
                                      source: :grant

  has_many   :grant_reviewers
  has_many   :reviewable_grants,      through: :grant_reviewers,
                                      source: :grant

  has_many   :submissions,            class_name: 'GrantSubmission::Submission',
                                      foreign_key: :created_id,
                                      inverse_of: :applicant
  has_many   :applied_grants,         through: :submissions,
                                      source: :grant

  has_many   :reviews,                inverse_of: :reviewer,
                                      foreign_key: :reviewer_id
  has_many   :reviewable_submissions, through: :reviews,
                                      source: :submission

  has_many   :grant_creator_requests, foreign_key: :requester_id,
                                      inverse_of: :requester

  validates :upn,               presence: true,
                                uniqueness: true
  validates :email,             presence: true,
                                uniqueness: true
  validates :first_name,        presence: true
  validates :last_name,         presence: true

  scope :alphabetical_order,    -> { order(last_name: :asc) }

  def name
    "#{first_name} #{last_name}".strip
  end
end
