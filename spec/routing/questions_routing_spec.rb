# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grants::QuestionsController, type: :routing do
  describe 'routing' do
    let(:grant) { FactoryBot.create(:grant) }
    let(:string_question) { FactoryBot.create(:string_question, grant_id: grant.id) }
    let(:integer_question) { FactoryBot.create(:integer_question, grant_id: grant.id) }

    skip 'routes to #index' do
      expect(get: 'grants/questions').to route_to('grants/questions#index')
    end

    skip 'routes to #new' do
      expect(get: '/questions/new').to route_to('grants/questions#new')
    end

    skip 'routes to #show' do
      expect(get: "grant/#{grant.id}/questions/1").to route_to('grants/questions#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: "grants/#{grant.id}/questions/#{string_question.id}/edit").to route_to('grants/questions#edit', grant_id: grant.id.to_s, id: string_question.id.to_s)
    end

    skip 'routes to #create' do
      expect(post: '/questions').to route_to('grants/questions#create')
    end

    it 'routes to #update via PUT' do
      expect(put: "grants/#{grant.id}/questions/#{string_question.id}").to route_to('grants/questions#update', grant_id: grant.id.to_s, id: string_question.id.to_s)
    end

    it 'routes to #update via PATCH' do
      expect(patch: "grants/#{grant.id}/questions/#{string_question.id}").to route_to('grants/questions#update', grant_id: grant.id.to_s, id: string_question.id.to_s)
    end

    skip 'routes to #destroy' do
      expect(delete: '/questions/1').to route_to('grants/questions#destroy', id: '1')
    end
  end
end
