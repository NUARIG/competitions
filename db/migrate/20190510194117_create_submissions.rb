class CreateSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :submission_forms do |t|
      t.string     :title,         null: false
      t.string     :description,   limit: 3000
      t.bigint     :created_id
      t.bigint     :updated_id
      t.timestamps
    end

    create_table :grant_forms do |t|
      t.references :grant,            null: false
      t.references :submission_form,  null: false
      t.integer    :display_order
      t.boolean    :disabled
      t.timestamps
    end

    create_table :submission_sections do |t|
      t.references :submission_form,  null: false
      t.string     :title
      t.integer    :display_order,    null: false
      t.boolean    :repeatable
      t.timestamps
    end

    create_table :submission_questions do |t|
      t.references  :submission_section,          null: false, foreign_key: true
      t.string      :text,                        null: false, limit: 4000
      t.string      :instruction,                 limit: 4000
      t.integer     :display_order,               null: false
      t.string      :export_code
      t.boolean     :is_mandatory
      t.string      :response_type,               null: false
      t.timestamps
    end

    create_table :submission_multiple_choice_options do |t|
      t.references :submission_question, null: false, index: { name: 'i_smco_on_submission_question_id' }
      t.string     :text,                null: false
      t.integer    :display_order,       null: false
      t.timestamps
    end

    create_table :submission_response_sets do |t|
      t.references :submission_form,      null: false
      t.bigint     :created_id,           null: false
      t.integer    :submission_section_id
      t.timestamps
    end

    create_table :submission_responses do |t|
      t.references :submission_response_set,           null: false
      t.references :submission_question,               null: false
      t.references :submission_multiple_choice_option, index: { name: 'i_sr_on_submission_multiple_choice_option_id' }
      t.string     :string_val
      t.text       :text_val
      t.decimal    :decimal_val
      t.datetime   :datetime_val
      t.boolean    :boolean_val
      t.timestamps
    end

    create_table :grant_response_sets do |t|
      t.references :grant
      t.references :submission_response_set
    end

    add_index :grant_response_sets,  [:grant_id, :submission_response_set_id], unique: true, name: 'i_gsrs_on_grant_id_and_submission_submission_id'

    add_index :submission_responses, [:submission_question_id, :submission_response_set_id], unique: true, name: 'i_sr_on_submission_question_id_and_submission_response_set_id'

    add_index :submission_forms,     [:title], unique: true

    add_index :grant_forms, [:submission_form_id, :grant_id], unique: true
    add_index :grant_forms, [:display_order, :grant_id],  unique: true

    add_index :submission_sections,  [:display_order, :submission_form_id],  unique: true, name: 'i_submission_sections_on_display_order_and_submission_form_id'

    add_index :submission_questions, [:display_order, :submission_section_id],   unique: true, name: 'i_sqs_on_display_order_and_submission_section_id'
    add_index :submission_questions, [:text,          :submission_section_id], unique: true

    add_index :submission_multiple_choice_options, [:display_order, :submission_question_id], unique: true, name: 'i_smco_on_display_order_and_submission_question_id'
    add_index :submission_multiple_choice_options, [:text,          :submission_question_id], unique: true, name: 'i_smco_on_text_and_submission_question_id'

    add_index :submission_response_sets, [:created_id, :submission_form_id], name: 'i_submission_response_sets_on_created_id_and_submission_form_id'
  end
end
