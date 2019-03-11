# frozen_string_literal: true

require 'rails_helper'

describe QuestionPolicy do
  subject { described_class.new(user, question) }

  context 'with user and question of the same organization' do
    let(:organization) { FactoryBot.create(:organization) }
    let(:grant) { FactoryBot.create(:grant, organization: organization) }
    let(:question) { FactoryBot.create(:string_question, grant: grant) }

    context 'questions for organization none users' do
      let(:user) { FactoryBot.create(:user, organization: organization) }

      it { is_expected.to forbid_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end

    context 'questions for organization viewer users' do
      let(:user) { FactoryBot.create(:user, organization: organization, organization_role: 'viewer') }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }

      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end

    context 'questions for organization editor users' do
      let(:user) { FactoryBot.create(:user, organization_role: 'editor', organization: organization) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }

      it { is_expected.to forbid_action(:destroy) }
    end

    context 'questions for organization admin users' do
      let(:user) { FactoryBot.create(:user, organization_role: 'admin', organization: organization) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end
  end
  context 'with user and question of different organizations' do
    context 'questions for organization admin users' do
      let(:organization1) { FactoryBot.create(:organization) }
      let(:organization2) { FactoryBot.create(:organization) }
      let(:grant) { FactoryBot.create(:grant, organization: organization1) }
      let(:question) { FactoryBot.create(:integer_question, grant: grant) }
      let(:user) { FactoryBot.create(:user, organization_role: 'admin', organization: organization2) }

      it { is_expected.to forbid_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end
end
