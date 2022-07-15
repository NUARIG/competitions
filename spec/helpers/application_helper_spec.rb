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

  context 'booleans' do
    describe '#on_off_boolean(boolean)' do
      it 'returns On when given a true boolean' do
        boolean = true
        helper.on_off_boolean(boolean).should eql("On")
      end

      it 'returns Off when given a false boolean' do
        boolean = false
        helper.on_off_boolean(boolean).should eql("Off")
      end
    end
  end
end
