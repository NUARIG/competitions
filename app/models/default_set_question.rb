# frozen_string_literal: true

class DefaultSetQuestion < ApplicationRecord
  belongs_to :default_set
  belongs_to :question
end
