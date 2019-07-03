# frozen_string_literal: true

class GrantReviewer < ApplicationRecord
  belongs_to :grant
  belongs_to :reviewer, class_name: 'User',
                        foreign_key: :reviewer_id

  validates_presence_of   :grant, :reviewer
  validates_uniqueness_of :reviewer, scope: :grant
end
