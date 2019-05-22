module DateOptionalTime
  extend ActiveSupport::Concern

  module ClassMethods
    def has_date_optional_time(datetime_comp, has_time_comp)
      dt_input = date_optional_time_attribute(datetime_comp)
      attr_reader dt_input
      validate {parse_date_string(self.send(dt_input), datetime_comp)}
      define_method("#{dt_input}=", ->(arg){set_date_opt_time(dt_input, datetime_comp, has_time_comp, arg)})
    end

    def date_optional_time_attribute(datetime_comp)
      "#{datetime_comp}_date_optional_time_magik".to_sym
    end
  end

  # Time.zone.parse will accept 2 digit years with potentially
  # suprising results.
  #  1.9.3-p484 :070 > Time.zone.parse('69-8-31')
  #   => Sun, 31 Aug 1969 00:00:00 CDT -05:00
  #  1.9.3-p484 :071 > Time.zone.parse('68-8-31')
  #   => Fri, 31 Aug 2068 00:00:00 CST -06:00
  # The Regex enforces a 4 digit year.
  # We can also safely assume >4 digit years are typos.
  # Time.strptime does not handle rails timezone properly.
  def parse_date_string(input, datetime_comp)
    if input.blank?
      return [nil, nil]
    end

    if input =~ %r{^\d{1,2}/\d{1,2}/\d{4}$}
      inputt, has_time = ["#{input}", false]
    else
      inputt, has_time = [nil, nil]
    end

    if input && (dt = Time.zone.parse(%r{^(\d{1,2})/(\d{1,2})/(\d{4})$}.match(inputt) do |m| "#{m[0]}" end ) rescue nil)
      [dt, has_time]
    else
      add_date_optional_time_error(datetime_comp)
      [nil, nil]
    end
  end

  def add_date_optional_time_error(datetime_comp)
    errors.add(datetime_comp, "must be a valid Date/Time in the format MM/DD/YYYY")
  end

  def date_optional_time_errors?(datetime_comp)
    errors[datetime_comp].blank?
  end

  def set_date_opt_time(dt_input, datetime_comp, has_time_comp, datestring)
    instance_variable_set("@#{dt_input}", datestring.strip)
    self[datetime_comp], self[has_time_comp] = parse_date_string(datestring.strip, datetime_comp)
  end

  def get_date_opt_time(datetime_comp, has_time_comp)
    self.send(has_time_comp) ? self.send(datetime_comp) : self.send(datetime_comp).try(:to_date)
  end

  # old data across many tables has various insignificant timestmaps. These should all be 0
  # see eb82f94086df6b30e3f44f3734c2feb592464b3a for more info
  def clear_bad_time(datetime_comp, has_time_comp)
    if !self.send(datetime_comp)
      nil
    else
      self.send(has_time_comp) ? self.send(datetime_comp) : Time.zone.parse("#{self.send(datetime_comp).strftime('%F')} 00:00")
    end
  end

  def form_dates_entry(datetime_comp, has_time_comp)
    [clear_bad_time(datetime_comp, has_time_comp), get_date_opt_time(datetime_comp, has_time_comp)]
  end
end
