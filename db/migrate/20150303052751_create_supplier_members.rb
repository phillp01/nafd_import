class CreateSupplierMembers < ActiveRecord::Migration
  def change
    create_table :supplier_members do |t|
      t.integer :member_id, :branch_id, :post_id, :index => true
      t.integer :grade, :index => true
      t.integer :area_id
      
      t.string :company_name, :address_1, :address_2, :address_3, :city, :region, :postcode, :country
      t.string :web_site, :email, :tel, :fax
      
      t.string :category, :sub_category, :index => true
      t.string :short_name_2, :index => true

      t.text :rendered_name
      t.text :rendered_contact

      t.timestamp :destroyed_at
      t.timestamps
    end
  end
end
