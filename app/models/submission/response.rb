module Submission
  class Response < ActiveRecord::Base
    self.table_name = 'form_responses'
    # TODO: Add _versions table
    # has_paper_trail

    belongs_to :submission,             class_name: 'Form::Submission',
                                        foreign_key: 'form_submission_id',
                                        inverse_of: :responses
    belongs_to :question,               class_name: 'Form::Question',
                                        foreign_key: 'form_question_id',
                                        inverse_of: :responses
    belongs_to :multiple_choice_option, class_name: 'Form::Answer',
                                        foreign_key: 'form_answer_id',
                                        inverse_of: :responses,
                                        optional: true

    validates_presence_of   :submission, :question
    validates_inclusion_of  :form_question_id, in: ->(it){it.submission.responded_to.questions.pluck(:id)}
    validates_inclusion_of  :form_answer_id,   in: ->(it){it.question.answers.pluck(:id)},
                                               allow_nil: true
    validates_uniqueness_of :form_question_id, scope: :form_submission_id
    validates_uniqueness_of :form_answer_id,   scope: :form_submission_id,
                                               allow_nil: true

    # custom validations to include question text in error message
    validate :length_if_short_text
    validate :number_if_number
    validate :attachment_size_if_document
    validate :response_if_mandatory

    include DateOptionalTime
    has_date_optional_time(:datetime_val, :boolean_val)

    include PartialDate
    has_partial_date(:partial_date_val)

    # PAPERCLIP
    # keep_old_files is cheap (and a bit shoddy) insurance, not an
    # advertised feature. Old files with the same name for the same
    # response will be overwritten. This is scoped to a response as
    # :id_partition makes a uniq folder for reach FormBuilder::Response
    # has_attached_file :document, keep_old_files: true, path:  "#{FILE_UPLOAD_PATH}/:class/:attachment/:id_partition/:filename"
    # do_not_validate_attachment_file_type :document

    def remove_document=(val)
      @remove_document = val # allows clearing file inputs to persist across validation errors
      if val == 1 || val == "1"
        self.document = nil
      end
    end
    def remove_document
      @remove_document ||= nil
    end

    def add_date_optional_time_error(datetime_comp)
      errors.add(self.class.date_optional_time_attribute(:datetime_val), "^#{question.text} must be a valid Date/Time in the format MM/DD/YYYY or MM/DD/YYYY HH:MM")
    end

    def date_optional_time_errors?(datetime_comp)
      errors[self.class.date_optional_time_attribute(:datetime_val)].blank?
    end

    # returns a pair of Time object for cycle date comparison and a string for display
    def to_form_date_pair
      case question.response_type.to_sym
      when :date_opt_time
        [datetime_val, response_value]
      when :partial_date
        time = get_partial_date(:partial_date_val).try(:to_time)
        time ? [time, time.strftime('%m/%d/%Y')] : [nil, nil]
      end
    end

    def response_value
      case question.response_type.to_sym
      when :pick_one
        answer.try(:text)
      when :number
        decimal_val
      when :short_text
        string_val
      when :long_text
        text_val
      when :date_opt_time
        get_date_opt_time(:datetime_val, :boolean_val)
      when :partial_date
        get_partial_date(:partial_date_val)
      when :file_upload
        document_file_name
      when :standard_answer
        standard_answer.try(:value)
      end
    end

    def formatted_response_value(format = nil)
      case question.response_type.to_sym
      when :pick_one
        if answer
          answer.to_formatted_s(format)
        else
          format == :export_multi_cols ? [nil, nil] : nil
        end
      when :standard_answer
        if standard_answer
          standard_answer.to_formatted_s(format)
        else
          format == :export_multi_cols ? [nil, nil] : nil
        end
      when :partial_date
        # when exporting to Excel, add an extra blank space at the end to force the cell style to be text
        # instead of the potential numeric if only year is present
        format == :export ? "#{response_value.to_s} " : response_value.to_s
      else
        response_value.to_s
      end
    end

    def form_field_name
      case question.response_type.to_sym
      when :pick_one
        :form_builder_answer_id
      when :number
        :decimal_val
      when :short_text
        :string_val
      when :long_text
        :text_val
      when :date_opt_time
        self.class.date_optional_time_attribute(:datetime_val)
      when :partial_date
        self.class.partial_date_virtual_attribute(:partial_date_val)
      when :file_upload
        :document
      when :standard_answer
        :form_builder_std_answer_id
      end
    end

    def response_value_raw
      case question.response_type.to_sym
      when :pick_one
        form_builder_answer_id
      when :number
        decimal_val
      when :short_text
        string_val
      when :long_text
        text_val
      when :date_opt_time
        get_date_opt_time(:datetime_val, :boolean_val)
      when :partial_date
        partial_date_val
      when :file_upload
        document_file_name
      when :standard_answer
        form_builder_std_answer_id
      end
    end

    private

    def response_if_mandatory
      if question.is_mandatory && response_value.blank?
        errors.add(form_field_name, "^#{question.text} can't be blank")
      end
    end

    def number_if_number
      input = read_attribute_before_type_cast('decimal_val')
      if question.response_type.to_sym == :number && !input.blank? && !parse_raw_value_as_a_number(input)
        errors.add(:decimal_val, "^#{question.text} is not a number")
      end
    end

    def length_if_short_text
      if question.response_type.to_sym == :short_text && string_val.length > 255
        errors.add(:string_val, "^#{question.text} can be a maxiumum of 255 characters (currently #{string_val.length})")
      end
    end

    def attachment_size_if_document
      mib = 1048576 # 2**20
      max = 15
      if question.response_type.to_sym == :file_upload && document_file_size && document_file_size > max*mib
        errors.add(:document, "^#{question.text} can be a maxiumum of #{max}MiB (#{document_file_name} is #{(document_file_size.to_f/mib).round(1)}MiB)")
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
  end
end
