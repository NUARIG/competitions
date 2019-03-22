# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:text) }
  it { is_expected.to respond_to(:help_text) }
  it { is_expected.to respond_to(:required) }

  it 'tracks whodunnit', versioning: true do
    is_expected.to be_versioned
  end
end
