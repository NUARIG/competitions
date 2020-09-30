module GrantSubmission
  class Response < ApplicationRecord
    include WithSubmissionState

    attr_accessor :remove_document

    self.table_name = 'grant_submission_responses'
    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::ResponseVersion' },
                    meta:     { grant_submission_question_id: :grant_submission_question_id }


    MAXIMUM_DOCUMENT_MEGABYTES          = 15
    MAXIMUM_DOCUMENT_FILE_SIZE          = MAXIMUM_DOCUMENT_MEGABYTES.megabytes
    READABLE_MAXIMUM_DOCUMENT_FILE_SIZE = "#{MAXIMUM_DOCUMENT_MEGABYTES}MB"

    ALLOWED_DOCUMENT_TYPES           = { 'PDF'  => '.pdf',
                                         'Word' => %w[.doc .docx .dotx] }.freeze
    ALLOWED_DOCUMENT_FILE_EXTENSIONS = ALLOWED_DOCUMENT_TYPES.values.flatten.freeze
    READABLE_ALLOWED_DOCUMENT_TYPES  = ALLOWED_DOCUMENT_TYPES.keys
                                       .to_sentence(words_connector: ', ',
                                                    two_words_connector: ' or ',
                                                    last_word_connector: ' or ').freeze

    belongs_to :submission,             class_name: 'GrantSubmission::Submission',
                                        foreign_key: 'grant_submission_submission_id',
                                        inverse_of: :responses
    belongs_to :question,               class_name: 'GrantSubmission::Question',
                                        foreign_key: 'grant_submission_question_id',
                                        inverse_of: :responses
    belongs_to :multiple_choice_option, class_name: 'GrantSubmission::MultipleChoiceOption',
                                        foreign_key: 'grant_submission_multiple_choice_option_id',
                                        inverse_of: :responses,
                                        optional: true

    has_one_attached :document

    validates_presence_of   :submission, :question
    validates_inclusion_of  :grant_submission_question_id,
                            in: -> (it) { it.submission.form.questions.pluck(:id) }
    validates_inclusion_of  :grant_submission_multiple_choice_option_id,
                            in: -> (it) { it.question.multiple_choice_options.pluck(:id) },
                            allow_nil: true
    validates_uniqueness_of :grant_submission_question_id,
                            scope: :grant_submission_submission_id
    validates_uniqueness_of :grant_submission_multiple_choice_option_id,
                            scope: :grant_submission_submission_id,
                            allow_nil: true

    validate :validate_by_response_type
    validate :response_if_mandatory, if: -> { question.is_mandatory? && (submission.submitted? || submission&.user_submitted_state == 'submitted') }
    validate :attachment_is_valid,   if: -> { document.attached? }


    after_save :purge_document

    include DateOptionalTime
    has_date_optional_time(datetime_comp: :datetime_val, has_time_comp: :boolean_val)

    def purge_document
      if remove_document == '1'
        document.purge
      end
    end
    
    def add_date_optional_time_error(datetime_comp)
      errors.add(self.class.date_optional_time_attribute(:datetime_val), "^#{question.text} must be a valid Date in the format MM/DD/YYYY")
    end

    def date_optional_time_errors?(datetime_comp)
      errors[self.class.date_optional_time_attribute(:datetime_val)].blank?
    end

    def response_value
      case question.response_type.to_sym
      when :pick_one
        multiple_choice_option.try(:text)
      when :number
        decimal_val
      when :short_text
        string_val
      when :long_text
        text_val
      when :date_opt_time
        get_date_opt_time(:datetime_val, :boolean_val)
      when :file_upload
        self.document.attached? ? self.document.filename : nil
      end
    end

    def formatted_response_value
      case question.response_type.to_sym
      when :pick_one
        multiple_choice_option.text
      else
        response_value.to_s
      end
    end

    def form_field_name
      case question.response_type.to_sym
      when :pick_one
        :grant_submission_multiple_choice_option_id
      when :number
        :decimal_val
      when :short_text
        :string_val
      when :long_text
        :text_val
      when :date_opt_time
        self.class.date_optional_time_attribute(:datetime_val)
      when :file_upload
        :document
      end
    end

    def submitted?
      self.submission.submitted? && (!self.submission.changed? || self.submission.changes.keys.include?('state'))
    end

    def changed_for_autosave?
      super || document.changed_for_autosave? if document.attached?
    end

    private

    def validate_by_response_type
      case question.response_type
      when 'number'
        validate_number_if_number_response
      when 'short_text'
        validate_length_if_short_text_response
      when 'file_upload'
        if document.attached?
          validate_attachment_size_if_file_upload_response && validate_attachment_type_if_file_upload_response
        end
      end
    end

    def response_if_mandatory
      errors.add(form_field_name, :blank, question: question.text) if response_value.blank?
    end

    def validate_number_if_number_response
      input = read_attribute_before_type_cast('decimal_val')
      if !input.blank? && !parse_raw_value_as_a_number(input)
        errors.add(:decimal_val, :not_a_number, question: question.text)
      end
    end

    def validate_length_if_short_text_response
      if string_val.length > 255
        errors.add(:string_val, :too_long, question: question.text)
      end
    end

    def validate_attachment_size_if_file_upload_response
      if document.blob.byte_size > MAXIMUM_DOCUMENT_FILE_SIZE
        errors.add(:document, :file_too_large, question: question.text,
                                               allowed_file_size: READABLE_MAXIMUM_DOCUMENT_FILE_SIZE,
                                               uploaded_file_size: (document.byte_size.to_f/(1.megabyte)).round(1))
        document = nil
      end
    end

    def validate_attachment_type_if_file_upload_response
      if ALLOWED_DOCUMENT_FILE_EXTENSIONS.exclude?(document.filename.extension_with_delimiter)
        errors.add(:document, :excluded_mime_type, question: question.text,
                                                   allowed_types: READABLE_ALLOWED_DOCUMENT_TYPES)
        document = nil
      end
    end

    #copied from ActiveModel::Validations::NumericalityValidator
    def parse_raw_value_as_a_number(raw_value)
      case raw_value
      when /\A0[xX]/
        nil
      else
        begin
          Kernel.Float(raw_value)
        rescue ArgumentError, TypeError
          nil
        end
      end
    end

    def attachment_is_valid
      errors.add(:document, :not_a_file_upload, question: question) unless question.response_type == 'file_upload'
    end

    # TODO: This will be needed in Rails 6.
    # def changed_for_autosave?
    #   super || file.changed_for_autosave?
    # end
  end
end
