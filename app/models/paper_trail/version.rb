# frozen_string_literal: true

module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern

    self.abstract_class = true
  end
end
