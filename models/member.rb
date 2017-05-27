class Member < ActiveRecord::Base
  include Geocoder::Model::ActiveRecord
  validates_presence_of :company_name, :address_1, :city, :region, :postcode, :country
  default_scope lambda {where :destroyed_at => nil}
  scope :with_email, lambda {where.not(:email => nil).where.not(:email => '')}
  
  # geocoded_by :address_for_geocode
  # after_validation :geocode, :if => :address_changed?
  
  def address_for_geocode
    add = []
    add << self.address_1
    add << self.address_2 if self.address_2.present?
    add << self.address_3 if self.address_3.present?
    add << self.city     if self.city.present?
    add << self.region   if self.region.present?
    add << self.postcode if self.postcode.present?
    add << (self.country.present? ? self.country : 'United Kingdom')
    add.join(', ')
  end

  def address_for_geocode_v2
    add = []
    add << self.address_1
    add << self.address_2 if self.address_2.present?
    add << self.address_3 if self.address_3.present?
    add << self.city     if self.city.present?
    add << (self.country.present? ? self.country : 'United Kingdom')
    add.join(', ')
  end

  def address_changed?
    address_1_changed? || address_2_changed? || address_3_changed? || 
         city_changed? || region_changed? || postcode_changed? ||
         latitude.blank? || longitude.blank?
    return postcode_changed? || latitude.blank? || longitude.blank?
  end
  
  def destroyed?
    destroyed_at.present?
  end
  
  def category
    21
  end

  def post_address
    [address_1, address_2, address_3].compact.join(", ")
  end
  
  comma do
    company_name 'post_title'
    __static_column__ 'post_author' do; 1; end
    company_name 'post_content'
    __static_column__ 'post_category' do; 'funeral-directors'; end
    __static_column__ 'post_tags' do; 'funeral-directors-1'; end
    __static_column__ 'post_type' do; 'gd_place'; end
    post_address 'post_address'
    city 'post_city'
    region 'post_region'
    country 'post_country'
    postcode 'post_zip'
    latitude 'post_latitude'
    longitude 'post_longitude'
    member_id 'geodir_member_id'
    branch_id 'geodir_branch_id'
    web_site 'geodir_website'
    email 'geodir_email_url'
    tel 'geodir_contact'
    fax 'geodir_fax'
    short_name 'geodir_short_name'
  end
end

class Inspector
  attr_accessor :id, :contact_id, :name

  def initialize(id, contact_id, name)
    self.id = id
    self.contact_id = contact_id
    self.name = name
  end
end

class Inspectors
  def self.data
    @data ||= [
      Inspector.new(-301185178, 1131553049, 'Shelagh Lightbody DipFD'),
      Inspector.new(-89252137,  41025678,   'Alan Sharpe'),
      Inspector.new(-84660946,  1413202689, 'Angela Preece'),
      Inspector.new(1,         -1683119283, 'Jenny Tomlinson Walsh'),
      Inspector.new(2,          31561,      'Roger Turberville'),
      Inspector.new(1125160396, 239486446,  'Robert Metcalf MBE DipFD'),
      # Inspector.new(1324617954, 1424693765, 'John Boyle DipFD MBIE'),
      Inspector.new(1324617954, 1424693765, 'Paul Harrison'),
      # Inspector.new(1346679263, 1128732890, 'Paul Harrison'),
      Inspector.new(1346679263, 1128732890, 'Nigel Cooper'),
      # Inspector.new(1547516815, 1259324348, 'Nigel Cooper'),
      Inspector.new(1547516815, 1259324348, 'Colin Erskine'),
      # Inspector.new(1750990777, 1192020376, 'Colin Erskine')
      Inspector.new(1750990777, 1192020376, 'John Boyle DipFD MBIE')
    ]
  end
  
  def self.find(id)
    data.select {|a| a.id == id}.first
  end
end

class DboInspection < ActiveRecord::Base
  self.primary_key = 'InspectionID'
end
class DboInspector < ActiveRecord::Base
  self.primary_key = 'InspectorID'
end
class DboMemberName < ActiveRecord::Base
  self.table_name = 'dbo_MemberNames'
  self.primary_key = 'MemberID'
end
class DboMember < ActiveRecord::Base
  self.primary_key = 'MemberID'
  # belongs_to :inspector, :foreign_key => 'InspectorID', :class => DboInspector
  def inspections
    @inspections ||= DboInspection.where("MemberID = ? and BranchID = ?", read_attribute('MemberID'), read_attribute('BranchID'))
                                  .order('InsDate DESC')
  end
  def inspection
    @inspection ||= inspections.first
  end

  def import_as_supplier(m, master_grade)
    m.company_name = read_attribute('CompanyName')
    m.address_1 = read_attribute('Address1')
    m.address_2 = read_attribute('Address2')
    m.address_3 = read_attribute('Address3')
    m.postcode  = read_attribute('PostCode')
    m.city      = read_attribute('Town')
    m.region    = read_attribute('County')
    m.country = read_attribute('CountryCode').blank? ? "United Kingdom" : read_attribute('CountryCode')

    m.web_site      = read_attribute('Web').present? ? "http://#{read_attribute('Web')}" : nil
    m.tel           = read_attribute('Telephone')
    m.fax           = read_attribute('Fax')
    m.email         = read_attribute('E-Mail')
    m.area_id       = read_attribute('AreaID')
    m.grade         = master_grade
    m.category      = read_attribute('NatureOfBusinessID')
    m.sub_category  = read_attribute('Category')
    m.short_name_2  = read_attribute('ShortName2')

    if read_attribute('IsActive')
      m.destroyed_at = nil
      puts "SUPPLIER_UPDATED: #{m.id}: #{m.company_name}"
    elsif not m.destroyed?
      $stderr.puts "SUPPLIER_DESTROYED: #{m.id}: #{m.company_name}"
      m.destroyed_at ||= Time.now
    end
    if m.changed?
      m.save(validate: false)
      # return true
    end
    # return false
    return m
  end
  
  def import_as_member(m, master_grade)
    m.company_name  = read_attribute('CompanyName')
    m.address_1     = read_attribute('Address1')
    m.address_2     = read_attribute('Address2')
    m.address_3     = read_attribute('Address3')
    m.postcode      = read_attribute('PostCode')
    m.city          = read_attribute('Town')
    m.region        = read_attribute('County')
    m.country       = read_attribute('CountryCode').blank? ? "United Kingdom" : read_attribute('CountryCode')

    m.location_confidence = 0 if m.address_changed?
  
    if (not m.location_confidence or m.location_confidence < 8) and read_attribute('IsActive')
      $stderr.puts " * #{m.member_id}: #{m.company_name}"
      confidence = m.location_confidence || 0
      confidence = 0 if m.address_changed?
      $stderr.puts "   Address Changed" if m.address_changed?

      if m.postcode? and m.country? and confidence < 6
      
      	Geocoder.configure(
  			:timeout  => 30,
  			:api_key  => 'b44f233db9bd4f139849b2a432e34f9b',
        	:use_https => true
		)        
      
        aa = Geocoder.search [m.postcode, m.country].join(', '), :lookup => :opencagedata
        a = aa.max_by{|i| i.data['confidence']}
        if a.present?
          confidence = a.data['confidence'] || confidence
        end
      end

      if confidence  < 6
      
      	Geocoder.configure(
  			:timeout  => 30,
  			:api_key  => 'b44f233db9bd4f139849b2a432e34f9b',
        	:use_https => true
		)
        bb = Geocoder.search m.address_for_geocode, :lookup => :opencagedata
        $stderr.puts " * #{m.member_id}: #{m.company_name}: Geocode opencagedata 1"
        b = bb.max_by{|i| i.data['confidence']}
        if b.present? and b.data['confidence'] > confidence
          a = b
          confidence = a.data['confidence']
        end
      end
      
      if confidence < 6
      
      Geocoder.configure(
      		:timeout  => 30,
  			:api_key  => 'b44f233db9bd4f139849b2a432e34f9b',
        	:use_https => true
		)
      
        bb = Geocoder.search m.address_for_geocode_v2, :lookup => :opencagedata
        $stderr.puts " * #{m.member_id}: #{m.company_name}: Geocode opencagedata 2"
        b = bb.max_by{|i| i.data['confidence']}
        if b.present? and b.data['confidence'] > confidence
          a = b
          confidence = a.data['confidence']
        end
      end

      if confidence < 8
      
      	Geocoder.configure(
      		:timeout  => 30,
  			:api_key  => 'AIzaSyBdWh2osjvjv1a_sgN3ngsfQm4aeB_jDRw',
        	:use_https => true
		)
      
        bb = Geocoder.search m.address_for_geocode_v2, :lookup => :google
        #bb = Geocoder.search("1 Twins Way, Minneapolis")
        $stderr.puts " * #{m.member_id}: #{m.company_name}: Geocode google"
        b = bb.first
        $stderr.puts " Address = #{m.address_for_geocode_v2} "
        $stderr.puts " bb = #{bb} "
        if b.present?
          a = b 
          confidence = 11
        end
      end

      #if confidence < 8
      #  bb = Geocoder.search m.address_for_geocode_v2, :lookup => :yahoo
      #  $stderr.puts " * #{m.member_id}: #{m.company_name}: Geocode yahoo"
      #  b = bb.first
      #  if b.present?
      #    a = b
      #    confidence = 12
      #  end
      #end

      if a.blank?
        $stderr.puts " ** GEOFAAAIL: Confidence: #{confidence}, #{m.id}: #{m.company_name}"
      else
        m.latitude = a.latitude
        m.longitude = a.longitude
        m.location_confidence = confidence
        m.city      = m.city || a.city
        m.region    = (a.try(:county) || a.try(:state) || a.try(:sub_state || m.city)) if m.region.blank?
        m.country   = a.country.blank? ? 'United Kingdom' : m.country
      end
    end

    m.tel         = read_attribute('Telephone')
    m.fax         = read_attribute('Fax')
    m.email       = read_attribute('E-Mail')
    m.area_id     = read_attribute('AreaID')
    m.grade       = master_grade
    m.short_name  = read_attribute('ShortName2')
    m.is_office   = read_attribute('IsOffice')
    m.is_unmanned   = read_attribute('Unmanned') == 1

    m.web_site      = read_attribute('Web').present? ? "http://#{read_attribute('Web')}" : nil
    m.inspector_name = Inspectors.find(read_attribute 'InspectorID').try(:name)
    m.member_name = DboMemberName.where(:MemberID => m.member_id).first.try(:'MemberName')
    
    
    begin
      if inspection.present?
        m.last_inspection_on   = inspection.read_attribute('InsDate')
        m.next_inspection_on   = inspection.read_attribute('DateReExamination')
        m.last_inspection_type = inspection.read_attribute('InsType')
        m.next_inspection_type = inspection.read_attribute('TypeReExamination')
      else
        m.last_inspection_on = m.next_inspection_on = m.last_inspection_type = m.next_inspection_type = nil
      end
    rescue ArgumentError
    end
  
    if read_attribute('IsActive')
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
    if m.changed?
      m.save(validate: false)
      # return true
    end
    # return false
    return m
  end
end
