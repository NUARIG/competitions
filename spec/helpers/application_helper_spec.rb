require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  def excel_worksheet_reserved_characters
    ['/', '*', '[', ']', ':', '?'].freeze
  end

  describe 'excel export' do
    let(:sheet_name) { Faker::Lorem.sentence }

    it 'removes backslash from sheet_names' do
      invalid_sheet_name = 'A name with a back\slash'
      prepared_sheet_name = prepare_excel_worksheet_name(sheet_name: invalid_sheet_name)
      expect(excel_worksheet_reserved_characters.none?{ |char| prepared_sheet_name.include?(char)}).to be true
    end

    it 'removes reserved characters from sheet_names' do
      invalid_character  = excel_worksheet_reserved_characters.sample
      invalid_sheet_name = sheet_name.insert(rand(sheet_name.length), invalid_character)

      prepared_sheet_name = prepare_excel_worksheet_name(sheet_name: invalid_sheet_name)
      expect(excel_worksheet_reserved_characters.none?{ |char| prepared_sheet_name.include?(char)}).to be true
    end
  end

  describe 'title_tag_content' do
    before(:each) do
      stub_const("COMPETITIONS_CONFIG", { application_name: 'TEST' })
    end

    it 'returns just application_name when not passed page_title' do
      expect(title_tag_content).to eql 'TEST'
    end

    it 'returns provided page_title with application_name' do
      expect(title_tag_content(page_title: 'Page Name')).to eql 'Page Name | TEST'
    end
  end

  describe 'full_root_url' do
    it 'constructs a full root url when given all segments' do
      stub_const("COMPETITIONS_CONFIG", { subdomain: 'subdomain',
                                          app_domain: 'domain.edu',
                                          default_url_options: {
                                              port: 123
                                            }
                                          })
      expect(full_root_url).to eql 'https://subdomain.domain.edu:123/'
    end

    context 'subdomain' do
      it 'can be nil' do
        stub_const("COMPETITIONS_CONFIG", { subdomain: nil,
                                            app_domain: 'domain.edu',
                                            default_url_options: {
                                                port: 123
                                              }
                                            })
        expect(full_root_url).to eql 'https://domain.edu:123/'
      end

      it 'can be empty string' do
        stub_const("COMPETITIONS_CONFIG", { subdomain: '',
                                            app_domain: 'domain.edu',
                                            default_url_options: {
                                                port: 123
                                              }
                                            })
        expect(full_root_url).to eql 'https://domain.edu:123/'
      end
    end

    context 'port' do
      it 'can be nil' do
        stub_const("COMPETITIONS_CONFIG", { subdomain: '',
                                            app_domain: 'localhost',
                                            default_url_options: {
                                                port: nil
                                              }
                                            })
        expect(full_root_url).to eql 'https://localhost/'
      end

      it 'can be an empty string' do
        stub_const("COMPETITIONS_CONFIG", { subdomain: '',
                                            app_domain: 'localhost',
                                            default_url_options: {
                                                port: ''
                                              }
                                            })
        expect(full_root_url).to eql 'https://localhost/'
      end

      it 'can be a string' do
        stub_const("COMPETITIONS_CONFIG", { subdomain: '',
                                            app_domain: 'localhost',
                                            default_url_options: {
                                                port: '123'
                                              }
                                            })
        expect(full_root_url).to eql 'https://localhost:123/'
      end

      it 'can be an integer' do
        stub_const("COMPETITIONS_CONFIG", { subdomain: '',
                                            app_domain: 'localhost',
                                            default_url_options: {
                                                port: 123
                                              }
                                            })
        expect(full_root_url).to eql 'https://localhost:123/'
      end
    end
  end
end
