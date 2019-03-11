# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :model do
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:short_name) }
  it { is_expected.to respond_to(:url) }

  let(:organization) { FactoryBot.build(:organization) }

  describe '#validations' do
    it 'validates presence of name' do
      organization.name = nil
      expect(organization).not_to be_valid
      expect(organization.errors).to include :name
    end

    it 'validates presence of short_name' do
      organization.short_name = nil
      expect(organization).not_to be_valid
      expect(organization.errors).to include :short_name
    end

    it 'validates presence of url' do
      organization.url = nil
      expect(organization).not_to be_valid
      expect(organization.errors).to include :url
    end

    it 'validates presence of url' do
      organization.url = nil
      expect(organization).not_to be_valid
      expect(organization.errors).to include :url
    end

    it 'validates format of url' do
      organization.url = 'http://collegeu.edu'
      expect(organization).to be_valid
      organization.url = 'college.com'
      expect(organization).not_to be_valid
      expect(organization.errors).to include :url
      organization.url = 'college .edu'
      expect(organization).not_to be_valid
      expect(organization.errors).to include :url
      organization.url = 'ftp://www.college.edu'
      expect(organization).not_to be_valid
      expect(organization.errors).to include :url
      organization.url = 'http://www.college.edu/ctsa/site'
      expect(organization).to be_valid
    end

    it 'validates unique name and short_name' do
      organization.save
      new_organization = Organization.new(name: organization.name, short_name: organization.short_name, url: organization.url)
      expect(new_organization).not_to be_valid
      expect(new_organization.errors).to include :name
      expect(new_organization.errors).to include :short_name
    end
  end
end
