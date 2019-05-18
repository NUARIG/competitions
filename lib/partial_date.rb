module PartialDate
  extend ActiveSupport::Concern

  module ClassMethods
    def has_partial_date(db_date_attribute)
      virtual_attribute = partial_date_virtual_attribute(db_date_attribute)

      self.columns_hash[virtual_attribute.to_s] = OpenStruct.new(cast_type: Date.new)

      define_method("#{virtual_attribute}=", ->(value) {
        self[db_date_attribute] = value.present? &&
                                  (value[1].present? || value[2].present? || value[3].present?) ?
                                  Date.new(value[1], value[2], value[3]).serialize : nil
      })

      define_method("#{virtual_attribute}", ->() {
        get_partial_date(db_date_attribute)
      })
    end

    def partial_date_virtual_attribute(db_date_attribute)
      "#{db_date_attribute}_virtual".to_sym
    end
  end

  def get_partial_date(db_date_attribute)
    self.send(db_date_attribute) ? Date.deserialize(self.send(db_date_attribute)) : nil
  end

  class Date
    attr_reader :year, :month, :day

    def klass
      nil
    end

    def initialize(year = nil, month = nil, day = nil)
      @year = year
      @month = month
      @day = day
    end

    def complete?
      year && month && day && month > 0 && day > 0
    end

    def to_time
      if complete?
        time = nil
        begin
          time = Time.zone.local(year, month, day)
        rescue
          # don't care about invalid time, just return nil
        end
        time
      end
    end

    def to_s
      serialize.gsub(/[_-]+$/, '')
    end

    def serialize
      year_str = year ? year.to_s.rjust(4, '0') : '____'
      month_str = month ? month.to_s.rjust(2, '0') : '__'
      day_str = day ? day.to_s.rjust(2, '0') : '__'
      "#{year_str}-#{month_str}-#{day_str}"
    end

    def self.deserialize(str)
      m = /^(____|\d{4})-(__|\d\d)-(__|\d\d)$/.match(str)
      unless m
        raise ArgumentError.new('Invalid date format')
      end
      (year_str, month_str, day_str) = m[1..3]
      year = year_str == '____' ? nil : year_str.to_i
      month = month_str == '__' ? nil : month_str.to_i
      day = day_str == '__' ? nil : day_str.to_i
      self.new(year, month, day)
    end

    def ==(o)
      o.class == self.class && o.state == state
    end

    protected

    def state
      [@year, @month, @day]
    end

  end
end
