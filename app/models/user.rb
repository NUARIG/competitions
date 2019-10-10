# frozen_string_literal: true

class User < ApplicationRecord
  attr_accessor :session_index

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :omniauthable, :database_authenticatable, :registerable, :recoverable, :validatable:rememberable
  devise :saml_authenticatable, :trackable, :timeoutable
  has_paper_trail versions: { class_name: 'PaperTrail::UserVersion' },
                  meta:     { user_id: :id } # added for convenience

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

  scope :order_by_last_name,    -> { order(last_name: :asc) }

  # https://github.com/apokalipto/devise_saml_authenticatable/issues/151
  def authenticatable_salt
    if self.session_index.present?
      self.read_attribute(session_index)
    else
      super
    end
  end

end
