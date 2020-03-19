module DateOptionalTime
  extend ActiveSupport::Concern

  # TODO: Remove optional time methods
  # TODO: Move to app/models/concerns?

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
    raise NoMethodError, "DateOptionalTime exptects #add_date_optional_time_error() to be defined in #{self.class}."
    # errors.add(datetime_comp, "must be a valid Date/Time in the format MM/DD/YYYY")
  end

  def date_optional_time_errors?(datetime_comp)
    raise NoMethodError, "DateOptionalTime exptects #date_optional_time_errors?() to be defined in #{self.class}."
    # errors[datetime_comp].blank?
  end

  def set_date_opt_time(dt_input, datetime_comp, has_time_comp, datestring)
    instance_variable_set("@#{dt_input}", datestring.strip)
    self[datetime_comp], self[has_time_comp] = parse_date_string(datestring.strip, datetime_comp)
  end

  def get_date_opt_time(datetime_comp, has_time_comp)
    self.send(has_time_comp) ? self.send(datetime_comp) : self.send(datetime_comp).try(:to_date)
  end
end
