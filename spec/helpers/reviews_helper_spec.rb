require 'rails_helper'

RSpec.describe ReviewsHelper, type: :helper do
  describe 'display_review_state' do
    it 'returns "Unknown" when passed a string with no translation ' do |variable|
      expect(helper.display_review_state("bad state")).to eq('Unknown')
    end

    it 'does not return Unknown for valid review states' do
      # See: config/locales/activerecord/review.yml
      Review.states.values.each do |state|
        expect(helper.display_review_state(state)).not_to eq 'Unknown'
      end
    end
  end
end
