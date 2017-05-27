class AddSeenAtToMembersAndSupplierMembers < ActiveRecord::Migration
  def change
    change_table :members do |t|
      t.timestamp :seen_at, :index => true
    end
    change_table :supplier_members do |t|
      t.timestamp :seen_at, :index => true
    end
  end
end
