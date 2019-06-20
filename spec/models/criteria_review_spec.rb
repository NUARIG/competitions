# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CriteriaReview, type: :model do
  it { is_expected.to respond_to(:criterion) }
  it { is_expected.to respond_to(:review) }
  it { is_expected.to respond_to(:score) }
  it { is_expected.to respond_to(:comment) }
end
