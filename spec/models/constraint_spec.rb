require 'rails_helper'

RSpec.describe Constraint, type: :model do
  it { is_expected.to respond_to(:field_type) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:value_type) }
  it { is_expected.to respond_to(:default) }
end
