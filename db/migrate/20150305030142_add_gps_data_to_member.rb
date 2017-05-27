class AddGpsDataToMember < ActiveRecord::Migration
  def change
    change_table :members do |t|
      t.text :data
      t.integer :location_confidence
    end
  end
end
