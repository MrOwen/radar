class CreateReportLocations < ActiveRecord::Migration
  def self.up
    create_table :report_locations do |t|
      t.string :detail
      t.integer :room

      t.timestamps
    end
  end

  def self.down
    drop_table :report_locations
  end
end
