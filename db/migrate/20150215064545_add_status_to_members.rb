class AddStatusToMembers < ActiveRecord::Migration
  def change
    change_table :members do |t|
      t.string :last_status, :index => true
    end
  end
end
