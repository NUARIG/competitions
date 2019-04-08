# frozen_string_literal: true

class AddDeletedAtToGrantGrantUserAndQuestion < ActiveRecord::Migration[5.2]
  UPDATED_TABLES = %i[grants grant_users questions]

  def self.up
    UPDATED_TABLES.each do |table|
      add_column table, :deleted_at, :datetime
    end
  end

  def self.down
    UPDATED_TABLES.each do |table|
      remove_column table, :deleted_at, :datetime
    end
  end
end
