# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :model do
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:slug) }
  it { is_expected.to respond_to(:url) }

  let(:organization) { FactoryBot.build(:organization) }

  describe '#validations' do
    it 'validates presence of name' do
      organization.name = nil
      expect(organization).not_to be_valid
      expect(organization.errors).to include :name
    end

    it 'validates presence of slug' do
      organization.slug = nil
      expect(organization).not_to be_valid
      expect(organization.errors).to include :slug
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
      organization.url = 'http://organization.org'
      expect(organization).to be_valid
      organization.url = 'http://www.acronym.gov'
      expect(organization).to be_valid
      organization.url = 'http://abc.acronym.gov'
      expect(organization).to be_valid
      organization.url = 'http://abc..xyz.acronym.gov'
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

    it 'validates unique name and slug' do
      organization.save
      new_organization = Organization.new(name: organization.name, slug: organization.slug, url: organization.url)
      expect(new_organization).not_to be_valid
      expect(new_organization.errors).to include :name
      expect(new_organization.errors).to include :slug
    end
  end
end
