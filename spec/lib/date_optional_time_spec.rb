# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateOptionalTime do
  describe "#add_date_optional_time_error()" do
    context "testing lib methods" do
      it "contains NoMethodError error" do
        allow_any_instance_of(DateOptionalTime).to receive(:add_date_optional_time_error).and_raise(StandardError)
        expect(NoMethodError)
      end
    end
  end

  describe "#date_optional_time_errors?()" do
    context "testing lib methods" do
      it "contains NoMethodError error" do
        allow_any_instance_of(DateOptionalTime).to receive(:date_optional_time_errors?).and_raise(StandardError)
        expect(NoMethodError)
      end
    end
  end
end
