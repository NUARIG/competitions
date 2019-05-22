class GrantForm < ApplicationRecord
  # TODO: add _versions table
  # has_paper_trail

  belongs_to :grant
  belongs_to :form, class_name: 'GrantSubmission::Form',
                    foreign_key: 'grant_submission_form_id',
                    inverse_of: :grant_forms

  scope :disabled,          ->(){ where(disabled: [true]) }       # DELETE
  scope :enabled,           ->(){ where(disabled: [nil, false]) } # DELETE
  scope :ordered_with_form, ->(){ includes(:form).order(:display_order) } # DELETE
  scope :with_questions,    ->(){ includes(form: :questions) }    # MOVE TO FORM

  validates_presence_of   :display_order, :grant, :form

  validates_uniqueness_of :grant_submission_form_id, scope: :grant_id
  validates_uniqueness_of :display_order,            scope: :grant_id

  # ADD reference column to Form in the Grant table
  # https://launchacademy.com/codecabulary/learn-rails/model-associations
  # CHANGE Grant Table to
  #    has_one Form
  # CHANGE Form Table to
  #    belongs_to Grant
  # MOVE validates_uniqueness_of :grant to :form
  # MOVE validates_uniqueness_of :f to :form

  def disabled_at
    if disabled
      time = versions.where("versions.object not like (?)", '%disabled: true%').maximum(:created_at)
      time ? time.in_time_zone : nil
    end
  end
end
