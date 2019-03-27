module GrantServices
  module CopyAttributes
    def self.call(grant_id)
      Grant.find(grant_id).dup.tap { |grant| grant.
        attribute_names.
        select { |attr_name| attr_name.match? '_date' }.
        each { |date| grant.write_attribute(date.to_sym, nil) } }
    end
  end
end
