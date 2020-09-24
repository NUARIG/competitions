class MovePanelAttributesToPanel < ActiveRecord::Migration[5.2]
  def up
    Grant.all.each do |grant|
      Panel.create!(grant: grant,
                   start_datetime:  grant.panel_date.present? ? grant.panel_date.beginning_of_day : nil,
                   end_datetime:    grant.panel_date.present? ? grant.panel_date.end_of_day : nil,
                   meeting_location: grant.panel_location)
    end

    remove_columns :grants, :panel_location, :panel_date
  end

  def down
    add_column :grants, :panel_date, :date
    add_column :grants, :panel_location, :text

    Panel.all.each do |panel|
      panel.grant.update(panel_location: panel.meeting_location,
                         panel_date: panel.start_datetime)
      panel.destroy
    end
  end
end
