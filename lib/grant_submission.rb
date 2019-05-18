class GrantSubmission < ActionView::Helpers::FormBuilder
  include NestedForm::BuilderMixin

  attr_accessor :read_only

  def text_field(attribute, options={})
    options.reverse_merge!(readonly: grant_disable_input?)
    super(attribute, options)
  end

  def text_area(attribute, options={})
    options.reverse_merge!(readonly: grant_disable_input?)
    super(attribute, options)
  end

  def select(method, choices, options = {}, html_options = {})
    html_options.reverse_merge!(disabled: grant_disable_input?)
    super(method, choices, options, html_options)
  end

  def check_box(method, options = {})
    options.reverse_merge!(disabled: grant_disable_input?)
    super(method, options)
  end

  # def submit def link_to_remove def link_to_add
  [:submit, :link_to_remove, :link_to_add].each do |m|
    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{m}(*args)
        if !grant_disable_input?
          super(*args)
        end
      end
    RUBY_EVAL
  end

  def date_opt_time_field(datetime_comp, has_time_component, options = {})
    dt_input = @object.class.date_optional_time_attribute(datetime_comp)
    value = if @object.date_optional_time_errors?(datetime_comp)
              @object.get_date_opt_time(datetime_comp, has_time_component).to_s
            else
              @object.send(dt_input)
            end
    @template.render(partial: 'date_optional_time_picker', locals:
           {f: self, dt_input: dt_input, value: value, has_time: @object.send(has_time_component),  disabled: grant_disable_input?, options: options})
  end

  def date_field(attr)
    text_field attr, size: 10, maxsize: 10, value: @object.send(attr), :data => {:behavior => 'datepicker'}, disabled: grant_disable_input?
  end

  def partial_date_field(attr, options = {})
    @template.render(partial: 'partial_date_field', locals:
           {f: self, attr: attr, disabled: grant_disable_input?, options: options})
  end

  def file_upload_field(saved_file, file_field, remove_file, link_text, link_location)
    @template.render(partial: 'file_upload_field', locals:
                     {f: self, saved_file: saved_file, file_field: file_field, remove_file: remove_file, link_text: link_text, link_location: link_location, disabled: grant_disable_input?})
  end

  def grant_disable_input?
    if options[:parent_builder]
      options[:parent_builder].instance_of?(GrantFormBuilder) ? options[:parent_builder].grant_disable_input? : !options[:parent_builder].object.available?
    else
      read_only || !object.available?
    end
  end
end
