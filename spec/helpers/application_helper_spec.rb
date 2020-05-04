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
end
