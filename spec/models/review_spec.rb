require 'rails_helper'

RSpec.describe Review, type: :model do
  it { is_expected.to respond_to(:submission) }
  it { is_expected.to respond_to(:reviewer) }
  it { is_expected.to respond_to(:overall_impact_score) }
  it { is_expected.to respond_to(:overall_impact_comment) }
end
