class CreateGrantSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :grant_submission_forms do |t|
      t.string     :title,         null: false
      t.string     :description,   limit: 3000
      t.bigint     :created_id
      t.bigint     :updated_id
      t.timestamps
    end

    # TODO:
    # add_column reference :grant on Form

    # TODO: DELETE THIS TABLE
    # create_table :grant_forms do |t|
    #   t.references :grant,            null: false
    #   t.references :grant_submission_form,  null: false
    #   t.integer    :display_order
    #   t.boolean    :disabled
    #   t.timestamps
    # end

    create_table :grant_submission_sections do |t|
      t.references :grant_submission_form,  null: false
      t.string     :title
      t.integer    :display_order,    null: false
      t.boolean    :repeatable
      t.timestamps
    end

    create_table :grant_submission_questions do |t|
      t.references  :grant_submission_section,    null: false, foreign_key: true
      t.string      :text,                        null: false, limit: 4000
      t.string      :instruction,                 limit: 4000
      t.integer     :display_order,               null: false
      t.string      :export_code
      t.boolean     :is_mandatory
      t.string      :response_type,               null: false
      t.timestamps
    end

    create_table :grant_submission_multiple_choice_options do |t|
      t.references :grant_submission_question, null: false, index: { name: 'i_gsmco_on_submission_question_id' }
      t.string     :text,                      null: false
      t.integer    :display_order,             null: false
      t.timestamps
    end

    create_table :grant_submission_submissions do |t|
      t.references :grant,                      null: false
      t.references :grant_submission_form,      null: false
      t.bigint     :created_id,                 null: false
      t.string     :title,                      null: false
      t.bigint     :grant_submission_section_id
      t.bigint     :parent_id
      t.timestamps
    end

    create_table :grant_submission_responses do |t|
      t.references :grant_submission_submission,             null: false, index: { name: 'i_gsr_on_grant_submission_submission_id' }
      t.references :grant_submission_question,               null: false, index: { name: 'i_gsr_on_grant_submission_question_id' }
      t.references :grant_submission_multiple_choice_option, index: { name: 'i_gsr_on_submission_multiple_choice_option_id' }
      t.string     :string_val
      t.text       :text_val
      t.decimal    :decimal_val
      t.datetime   :datetime_val
      t.boolean    :boolean_val
      t.timestamps
    end

    add_index :grant_submission_responses,   [:grant_submission_question_id, :grant_submission_submission_id], unique: true, name: 'i_gsr_on_submissisubmission_id'

    add_index :grant_submission_forms,       [:title], unique: true

    add_index :grant_forms,                  [:grant_submission_form_id, :grant_id], unique: true
    add_index :grant_forms,                  [:display_order, :grant_id],  unique: true

    add_index :grant_submission_sections,    [:display_order, :grant_submission_form_id],  unique: true, name: 'i_submission_sections_on_display_order_and_submission_form_id'

    add_index :grant_submission_questions,   [:display_order, :grant_submission_section_id], unique: true, name: 'i_sqs_on_display_order_and_submission_section_id'
    add_index :grant_submission_questions,   [:text,          :grant_submission_section_id], unique: true, name: 'i_gsq_on_text_and_grant_submission_section_id'

    add_index :grant_submission_multiple_choice_options, [:display_order, :grant_submission_question_id], unique: true, name: 'i_smco_on_display_order_and_submission_question_id'
    add_index :grant_submission_multiple_choice_options, [:text,          :grant_submission_question_id], unique: true, name: 'i_smco_on_text_and_submission_question_id'

    add_index :grant_submission_submissions, [:created_id, :grant_submission_form_id], name: 'i_gss_on_created_id_and_submission_form_id'
    add_index :grant_submission_submissions, [:grant_id, :created_id], name: 'i_gss_on_grant_id_and_created_id'

  end
end
