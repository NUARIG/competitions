require 'rails_helper'

RSpec.describe Criterion, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:is_mandatory) }
  it { is_expected.to respond_to(:show_comment_field) }
end
