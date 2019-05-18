module Submission
  class Section < ApplicationRecord
    self.table_name = 'submission_sections'

    # TODO: Add _version table
    #has_paper_trail ignore: [:display_order]

    belongs_to :form,    class_name: 'Submission::Form',
                         foreign_key: 'submission_form_id',
                         inverse_of: :sections
    has_many :questions, class_name: 'Submission::Question',
                         dependent: :destroy,
                         foreign_key: 'submission_section_id',
                         inverse_of: :section
    # has_one :condition_group, as: :owner,
    #                           dependent: :destroy
    #                           optional: true

    scope :repeatable,     -> { where(repeatable: true) }
    scope :non_repeatable, -> { where(repeatable: [nil, false]) }

    accepts_nested_attributes_for :questions, allow_destroy: true

    validates_presence_of :form, :display_order
    validates_numericality_of :display_order, only_integer: true, greater_than: 0
    validates_length_of :title, maximum: 255

    def self.human_readable_attribute(attr)
      {}[attr] || attr.to_s.humanize
    end

    def to_export_hash
      {
          title: title,
          display_order: display_order,
          repeatable: repeatable,
          questions_attributes: questions.map(&:to_export_hash)
      }
    end

    def available?
      new_record? || form.available?
    end

    def text
      title
    end
  end
end
