# frozen_string_literal: true

module DefaultSetsHelper
  def default_set_select_options
    DefaultSet.all.pluck(:name, :id)
  end
end
