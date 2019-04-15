# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grants::HomeDecorator do
  before do
    @open_grant = create(:open_grant_with_users_and_questions)
    @decorated_open_grant = Grants::HomeDecorator.decorate(@open_grant)
  end

  describe '#submission_period' do
    it 'formats submission dates ' do
      expect(@decorated_open_grant.submission_period).to eql("#{@open_grant.submission_open_date} - #{@open_grant.submission_close_date}")
    end
  end
end
