class Member < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.integer :member_id, :branch_id, :post_id, :index => true
      t.integer :grade, :index => true
      t.integer :area_id
      
      t.string :company_name, :address_1, :address_2, :address_3, :city, :region, :postcode, :country
      t.string :web_site, :email, :tel, :fax
      t.float :latitude, :longitude
      
      t.string :category, :sub_category, :index => true
      t.string :keywords, :short_name, :index => true
      
      t.string :inspector_name, :index => true
      t.timestamp :last_inspection_on, :next_inspection_on
      t.string :last_inspection_type, :next_inspection_type
      t.boolean :is_office, :is_unmanned
      
      t.timestamp :destroyed_at
      t.timestamps
    end

    create_table :local_associations do |t|
      t.integer :nafd_local_id
      t.boolean :is_active
      t.string :name, :secretary, :index => true
      t.string :address_1, :address_2, :address_3, :address_4, :postcode, :country
      t.string :tel, :mobile, :fax, :email
      t.text :rendered_name, :rendered_address, :rendered_contact
    end

    create_table :area_federations do |t|
      t.integer :nafd_area_id
      t.boolean :is_active
      t.string :name, :secretary, :index => true
      t.string :address_1, :address_2, :address_3, :address_4, :postcode, :country
      t.string :tel, :mobile, :fax, :email
      t.text :rendered_name, :rendered_address, :rendered_contact
    end
  end
end
