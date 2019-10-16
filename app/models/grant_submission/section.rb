module GrantSubmission
  class Section < ApplicationRecord
    self.table_name = 'grant_submission_sections'

    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::SectionVersion' },
                    meta: { grant_submission_form_id: :grant_submission_form_id },
                    ignore: [:display_order]

    belongs_to :form,    class_name: 'GrantSubmission::Form',
                         foreign_key: 'grant_submission_form_id',
                         inverse_of: :sections
    has_many :questions, class_name: 'GrantSubmission::Question',
                         dependent: :destroy,
                         foreign_key: 'grant_submission_section_id',
                         inverse_of: :section

    accepts_nested_attributes_for :questions, allow_destroy: true

    validates_presence_of     :form, :title
    validates_length_of       :title, maximum: 255
    validates_uniqueness_of   :title, scope: :form
    validates_uniqueness_of   :display_order, scope: :form
    validates_numericality_of :display_order, only_integer: true, greater_than: 0, on: :update, if: -> { display_order.present? }

    def available?
      new_record? || form.available?
    end
  end
end
