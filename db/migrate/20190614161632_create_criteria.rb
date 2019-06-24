class CreateCriteria < ActiveRecord::Migration[5.2]
  def change
    create_table :criteria do |t|
      t.references :grant
      t.string     :name
      t.text       :description
      t.boolean    :is_mandatory,       null: false, default: true
      t.boolean    :show_comment_field, null: false, default: true
      t.boolean    :allow_no_score,     null: false, default: true

      t.timestamps
    end
  end
end
