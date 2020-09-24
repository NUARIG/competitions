class CreatePanels < ActiveRecord::Migration[5.2]
  def change
    create_table :panels do |t|
      t.references  :grant,           null: false, foreign_key: true
      t.datetime    :start_datetime
      t.datetime    :end_datetime
      t.text        :instructions
      t.string      :meeting_link
      t.text        :meeting_location

      t.timestamps
    end
  end
end
