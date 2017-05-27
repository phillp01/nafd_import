
class NafdInspector < ActiveMDB::Base
  set_mdb_file 'mdb/NAFD_Web_DB.mdb'
  set_table_name 'dbo_Inspectors'
  set_primary_key 'InspectorID'

  def contact
    @contact ||= NafdContact.find_where("ContactID = #{self.contact_id}").first
  end
  
  def name
    @name ||= contact.try :name
  end
end

class NafdContact < ActiveMDB::Base
  set_mdb_file 'mdb/NAFD_Data.mdb'
  set_table_name 'tblContacts'
  set_primary_key 'ContactID'

  def name
    @name ||= "#{FirstName} #{LastName}"
  end
end

class NafdMember < ActiveMDB::Base
  set_mdb_file 'mdb/NAFD_Web_DB.mdb'
  set_table_name 'dbo_Members'
  set_primary_key 's_guid'

  def import_as_supplier(m)
    m.company_name = company_name
    m.address_1 = address1 unless address1.blank?
    m.address_2 = address2 unless address2.blank?
    m.address_3 = address3 unless address3.blank?
    m.postcode = post_code unless post_code.blank?
    m.city = town unless town.blank?
    m.region = county unless county.blank?
    m.country = country_code.blank? ? "United Kingdom" : country_code

    m.tel = telephone if telephone.present?
    m.fax = fax if fax.present?
    m.email = e_mail if e_mail.present?
    m.web_site = "http://#{web}" if web.present?
    m.area_id = area_id
    m.grade = grade
    m.category = nature_of_business_id
    m.sub_category = category
    m.short_name_2 = short_name2

    if is_active
      m.destroyed_at = nil
      puts "SUPPLIER_UPDATED: #{m.id}: #{m.company_name}"
    else
      $stderr.puts "SUPPLIER_DESTROYED: #{m.id}: #{m.company_name}"
      m.destroyed_at ||= Time.now
    end
    # if m.changed?
      m.save(validate: false)
      # return true
    # end
    # return false
    return m
  end
  
  def import_as_member(m)
    m.company_name = company_name
    m.address_1 = address1 unless address1.blank?
    m.address_2 = address2 unless address2.blank?
    m.address_3 = address3 unless address3.blank?
    m.postcode = post_code unless post_code.blank?
    m.city = town unless town.blank?
    m.city = town unless town.blank?
    m.region = county unless county.blank?
    m.country = country_code.blank? ? "United Kingdom" : country_code
  
    if not m.location_confidence or m.location_confidence < 6 or m.address_changed?
      confidence = m.location_confidence || 0

      if m.postcode? and m.country? and confidence < 6
        aa = Geocoder.search [m.postcode, m.country].join(', ')
        a = aa.max_by{|i| i.data['confidence']}
        confidence = a.blank? ? 0 : a.data['confidence']
      end
      
      if confidence < 0
        bb = Geocoder.search m.address_for_geocode
        b = bb.max_by{|i| i.data['confidence']}
        a = b if b.present? and b.data['confidence'] > confidence
      end

      if confidence < 0
        bb = Geocoder.search m.address_for_geocode_v2
        b = bb.max_by{|i| i.data['confidence']}
        a = b if b.present? and b.data['confidence'] > confidence
      end

      if confidence < 6
        bb = Geocoder.search m.address_for_geocode, :lookup => :google
        b = bb.max_by{|i| i.data['confidence']}
        a = b if b.present? and b.data['confidence'] > confidence
      end

      if a.blank?
        $stderr.puts " ** GEOFAIL: Confidence: #{confidence}, #{m.id}: #{m.company_name}"
      else
        m.latitude = a.latitude
        m.longitude = a.longitude
        m.location_confidence = a.data['confidence']
        m.city      = m.city || a.city
        m.region    = (a.try(:county) || a.try(:state) || a.try(:sub_state || m.city)) if m.region.blank?
        m.country   = a.country.blank? ? 'United Kingdom' : m.country
      end
    end

    m.tel = telephone if telephone.present?
    m.fax = fax if fax.present?
    m.email = e_mail if e_mail.present?
    m.web_site = "http://#{web}" if web.present?
  
    m.area_id = area_id
    m.grade = grade
    m.short_name = short_name2
    m.inspector_name = Inspectors.find(inspector_id).try(:name)
    
    begin
      inspection = NafdInspection.last_for(member_id, branch_id)
      if inspection.present?
        # m.inspector_name = inspection.inspector.try(:name)
        m.last_inspection_on = Date.strptime(inspection.ins_date, '%m/%d/%y') if inspection.ins_date.present?
        m.next_inspection_on = Date.strptime(inspection.date_re_examination, '%m/%d/%y') if inspection.date_re_examination.present?
        m.last_inspection_type = inspection.ins_type
        m.next_inspection_type = inspection.type_re_examination
      end
    rescue ArgumentError
    end
  
    if is_active
      m.last_status = m.valid? ? "VALID" : "INVALID"
      m.destroyed_at = nil if m.destroyed_at?
      puts "MEMBER_ACTIVE-: #{m.id}: #{m.last_status}: #{m.company_name}"
    elsif m.last_status != 'DELETED' or !m.destroyed_at?
      $stderr.puts "MEMBER_DESTROYED-: #{m.id}: #{m.last_status}: #{m.company_name}"
      m.last_status = 'DELETED'
      m.destroyed_at = Time.now
    else
      puts "MEMBER_ALREADY_DELETED: #{m.id}: #{m.last_status}: #{m.company_name}"
    end
    # if m.changed?
      m.save(validate: false)
      # return true
    # end
    # return false
    return m
  end
end

class NafdInspection < ActiveMDB::Base
  set_mdb_file 'mdb/NAFD_Web_DB.mdb'
  set_table_name 'dbo_Inspections'
  set_primary_key 'InspectionID'
  
  def self.last_for(member_id, branch_id)
    fw = find_where("MemberID = #{member_id} AND BranchID = #{branch_id}")
    return if fw.blank?
    fw.max_by do |a,b|
      # puts ""
      # puts a.inspect
      aa = a.ins_date.present? ? Date.strptime(a.ins_date, '%m/%d/%y') : nil # Date.parse('01/01/1970')
      # bb = Date.strptime(b.ins_date, '%m/%d/%y') if b.ins_date.present?
      # aa <=> bb
      aa
    end
  end
  def inspector
    @inspector ||= Inspectors.find(ins_contact_id)
  end
end

class NafdLocalSecretary < ActiveMDB::Base
  set_mdb_file 'mdb/NAFD_Web_DB.mdb'
  set_table_name 'dbo_LocalSecretaries'
  set_primary_key 'LocalSecretaryID'
  
  def load_it
    LocalAssociation.create :nafd_local_id => local_secretary_id, :name => local_name, 
                            :secretary => [contact_title, contact_first_name, contact_last_name].compact.join(' '),
                            :address_1 => c_addr1, :address_2 => c_addr2, :address_3 => c_addr3, 
                            :address_4 => caddr4, :postcode => c_post_code, :country => 'United Kingdom',
                            :tel => contact_tel, :mobile => contact_mobile, :fax => contact_fax,
                            :email => contact_email
  end
  
  def self.load_it_all
    # self.find_all.map {|i| i.load_it}
    data = `mdb-export mdb/NAFD_Web_DB.mdb dbo_LocalSecretaries`
    CSV.parse(data, :headers => true) do |r|
      la = LocalAssociation.find_or_initialize_by(:nafd_local_id => r['LocalSecretaryID'])
      la.update_attributes :name => r['LocalName'], 
                           :secretary => [r['ContactTitle'], r['ContactFirstName'], r['ContactLastName']].compact.join(' '),
                           :address_1 => r['CAddr1'], :address_2 => r['CAddr2'], 
                           :address_3 => r['CAddr3'], :address_4 => r['Caddr4'], 
                           :postcode => r['CPostCode'], :country => 'United Kingdom',
                           :tel => r['ContactTel'], :mobile => r['ContactMobile'], :fax => r['ContactFax'],
                           :email => r['ContactEmail'], :is_active => (r['IsNotActive'].to_i == 0 || r['IsNotActive'].blank?)
    end
  end
end

class NafdAreaSecretary < ActiveMDB::Base
  set_mdb_file 'mdb/NAFD_Web_DB.mdb'
  set_table_name 'dbo_AreaSecretaries'
  set_primary_key 'AreaSecretaryID'

  def load_it
    AreaFederation.create :nafd_area_id => area_secretary_id, :name => area_name, :secretary => name,
                          :address_1 => c_addr1, :address_2 => c_addr2, :address_3 => c_addr3,
                          :address_4 => caddr4, :postcode => c_post_code, :country => 'United Kingdom',
                          :tel => contact_tel, :mobile => contact_mobile, :fax => contact_fax,
                          :email => contact_email
  end

  def self.load_it_all
    # NafdAreaSecretary.find_all.each {|i| i.load_it}
    data = `mdb-export mdb/NAFD_Web_DB.mdb dbo_AreaSecretaries`
    CSV.parse(data, :headers => true) do |r|
      af = AreaFederation.find_or_initialize_by(:nafd_area_id => r['AreaSecretaryID'])
      af.update_attributes :name => r['AreaName'], :secretary => r['Name'],
                           :address_1 => r['CAddr1'], :address_2 => r['CAddr2'], 
                           :address_3 => r['CAddr3'], :address_4 => r['Caddr4'], 
                           :postcode => r['CPostCode'], :country => 'United Kingdom',
                           :tel => r['ContactTel'], :mobile => r['ContactMobile'], :fax => r['ContactFax'],
                           :email => r['ContactEmail'], :is_active => (r['IsNotActive'].blank? || r['IsNotActive'].to_i == 0)
    end
  end
end
