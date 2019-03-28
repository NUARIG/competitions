class CreateResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :responses do |t|
      t.references :grant
      t.references :question
      t.text :type
      t.integer :integer_response
      t.float :float_response
      t.string :string_response
      # t.text :text_responset
      # t.boolean :boolean_response
      # t.text :array_response, array: true, default: []
      # t.references :document

      t.timestamps
    end
  end
end
