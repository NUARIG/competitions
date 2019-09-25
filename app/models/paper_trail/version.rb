# frozen_string_literal: true

module PaperTrail
  class Version < ApplicationRecord
    include PaperTrail::VersionConcern
    self.abstract_class = true
  end
end
