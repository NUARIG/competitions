# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# NOTE: Remove form_with_error tag on score-related buttons & labels
#       Applies to _reviews_by_criteria and _overall_impact partials
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
	if instance.instance_variable_get('@method_name').include?('_score')
    html_tag.html_safe
  else
    %(<div class=\"field_with_errors\">#{html_tag}</div>).html_safe
  end
end
