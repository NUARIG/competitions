# uses NestedForms FormBuilder
class GrantSubmissionFormBuilder < ActionView::Helpers::FormBuilder
  include NestedForm::BuilderMixin

  attr_accessor :read_only

  def text_field(attribute:, options: {})
    options.reverse_merge!(readonly: grant_disable_input?) unless options[:disabled]
    super(attribute, options)
  end

  def text_area(attribute:, options: {})
    options.reverse_merge!(readonly: grant_disable_input?) unless options[:disabled]
    super(attribute, options)
  end

  def select(method:, choices:, options: {}, html_options: {})
    html_options[:disabled] = grant_disable_input? unless html_options[:disabled]
    super(method, choices, options, html_options)
  end

  # dynamically generates thse methods
  #   def submit def link_to_remove def link_to_add
  %i[submit link_to_remove link_to_add].each do |method|
    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{method}(*args)
        if !grant_disable_input?
          super(*args)
        end
      end
    RUBY_EVAL
  end

  def date_opt_time_field(datetime_comp, has_time_component, options = {})
    dt_input = @object.class.date_optional_time_attribute(datetime_comp)
    value = if @object.date_optional_time_errors?(datetime_comp)
              @object.get_date_opt_time(datetime_comp, has_time_component)&.to_fs
            else
              @object.send(dt_input)
            end
    @template.render(partial: 'date_optional_time_picker',
                     locals: { f: self,
                               css_id: "grant_submission_question_id_#{object.grant_submission_question_id}",
                               dt_input: dt_input,
                               value: value,
                               has_time: false,
                               disabled: grant_disable_input?,
                               options: options} )
  end

  def date_field(attr)
    text_field attr, size: 10, maxsize: 10, value: @object.send(attr), :data => {:behavior => 'datepicker'}, disabled: grant_disable_input?
  end

  def file_upload_field(has_saved_file:, file_field:, remove_document:, document:)
    @template.render(partial: 'file_upload_field',
                     locals: { f: self,
                               has_saved_file: has_saved_file,
                               remove_document: remove_document,
                               document: document,
                               disabled: grant_disable_input? } )
  end

  def grant_disable_input?
    if options[:parent_builder]
      options[:parent_builder].instance_of?(self.class) ? options[:parent_builder].grant_disable_input? : !options[:parent_builder].object.available?
    else
      read_only || !object.available?
    end
  end
end
