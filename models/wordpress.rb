ASCII_APPROXIMATIONS = {198 => "AE", 208 => "D", 216 => "O", 222 => "Th", 223 => "ss", 230 => "ae", 
                        240 => "d", 248 => "o", 254 => "th"}.freeze
def slugger(item)
  s = ActiveSupport::Multibyte.proxy_class.new(item)
  s = s.normalize(:kd).unpack('U*')
  s = s.inject([]) do |a, u|
    if ASCII_APPROXIMATIONS[u]
      a += ASCII_APPROXIMATIONS[u].unpack('U*')
    elsif (u < 0x300 || u > 0x036F)
      a << u
    end
    a
  end
  s = s.pack('U*')
  s.to_s
  s.downcase!
  s.strip!
  s.gsub!(/[^a-z0-9\s-]/, '') # Remove non-word characters
  s.gsub!(/\s+/, '-')     # Convert whitespaces to dashes
  s.gsub!(/-\z/, '')      # Remove trailing dashes
  s.gsub!(/-+/, '-')      # get rid of double-dashes
  s.to_s
end


class PlacePost < WPPublicModel
  self.table_name  = :wp_posts
  self.primary_key = :ID

  has_one :geodir_place, :foreign_key => :post_id, :autosave => true, :dependent => :destroy
  has_many :term_relationships, :foreign_key => :object_id, :dependent => :destroy, :autosave => true
  default_scope lambda {where(:post_type => 'gd_place')}
  
  validates_presence_of :post_author, :post_title, :post_status, :comment_status, :ping_status, 
                        :post_parent, :menu_order, :post_type, :comment_count
  validates_associated :geodir_place

  before_validation :set_defaults, :on => :create
  before_validation :set_updates
  # after_save :save_related
  # def save_related
  #   geodir_place.save if geodir_place.changed?
  # end
  
  def set_defaults
    published_on = Time.now
    self.attributes = {:post_author => 1, :post_date => published_on, :post_date_gmt => published_on.getutc, 
                       :post_status => 'publish', :comment_status => 'closed',
                       :ping_status => 'closed', :post_parent => 0, :menu_order => 0, :post_type => 'gd_place',
                       :comment_count => 0, :post_content => '', 
                       :post_excerpt => '', :to_ping => '', :pinged => '', :post_content_filtered => ''}
  end
  
  def set_updates
    published_on = Time.now
    self.attributes = {:post_modified => published_on, :post_modified_gmt => published_on.getutc}
  end
  
  def update_attributes_from_member(member)
    self.post_title = member.company_name
    self.geodir_place ||= build_geodir_place
    unless term_relationships.map {|i| i.term_taxonomy_id}.include?(21)
      if new_record?
        self.term_relationships.build(:term_taxonomy_id => 21)
      else
        self.term_relationships.create(:term_taxonomy_id => 21)
      end
    end
    geodir_place.update_attributes_from_member(member)
  end
end

class PostLocation < WPPublicModel
  self.table_name  = :wp_geodir_post_locations
  self.primary_key = :location_id
  
  # validates_presence_of :country, :region, :city, :country_slug, :region_slug, :city_slug, :city_latitude, :city_longitude
  
  def self.find_or_create_from_attributes(country, region, city, latitude, longitude)
    find_or_initialize_by(:country_slug => slugger(country || ''), :region_slug => slugger(region || ''), 
                          :city_slug => slugger(city || '')).tap do |location|
                          
      location.update_attributes :country => (country || ''), :region => (region || ''), :city => (city || ''),
                          :city_latitude => latitude, :city_longitude => longitude, :is_default => 0,
                          :city_meta => '', :city_desc => ''
    end
  end
  
  def locations
    "[#{city_slug}],[#{region_slug}],[#{country_slug}]"
  end
end

class PostIcon < WPPublicModel
  self.table_name  = :wp_geodir_post_icon
  belongs_to :geodir_place, :foreign_key => :post_id
end

class GeodirPlace < WPPublicModel
  self.table_name  = :wp_geodir_gd_place_detail
  self.primary_key = :post_id
  
  belongs_to :place_post, :foreign_key => :post_id
  belongs_to :post_location
  has_one :post_icon, :foreign_key => :post_id, :dependent => :destroy, :autosave => true
  # has_many :post
  
  before_validation :set_defaults, :on => :create
  before_validation :set_marker_json, :if => :position_changed?
  
  validates_presence_of :post_title, :post_status, :default_category, :post_location_id, :marker_json, 
                        :submit_time, :submit_ip, :post_locations, :gd_placecategory, :post_address,
                        :post_city, :post_country, :post_latitude, :post_longitude, :post_latlng,
                        :geodir_member_id, :geodir_branch_id
  # validates_presence_of :post_region, :post_zip, :unless => lambda {|gd| gd.geodir_grade == 50}
                        
  # after_save :save_post_icon
  # def save_post_icon
  #   post_icon.save if post_icon.changed?
  # end
  def update_attributes_from_member(member)
    self.attributes = {:post_title => member.company_name, 
                       :post_address => [member.address_1, member.address_2, member.address_3].compact.join("\n"),
                       :post_region => member.region, :post_city => member.city, :post_country => member.country,
                       :post_zip => member.postcode, :post_latitude => member.latitude, :post_longitude => member.longitude,
                       :geodir_contact => member.tel, :geodir_website => member.web_site,
                       :geodir_email_url => member.email, :geodir_fax => member.fax, :geodir_member_id => member.member_id,
                       :geodir_branch_id => member.branch_id, :geodir_short_name => member.short_name,
                       :geodir_grade => member.grade}
    location = PostLocation.find_or_create_from_attributes(member.country, member.region, member.city, 
                                                           member.latitude, member.longitude)
    self.attributes = {:post_locations => location.locations, :post_location_id => location.id}
   #   if country == 'Nigeria'
    	
     #   $stderr.puts latitude
    #	$stderr.puts longitude                          
    #end
  
  	$stderr.puts member.country
  end

  def set_defaults
    self.attributes = {:post_status => 'publish', :expire_date => 'Never', :submit_time => Time.now.getutc.to_i, 
                       :submit_ip => '127.0.0.1', :post_latlng => 1, :default_category => 21,
                       :gd_placecategory => ",21,"}
  end
  
  def position_changed?
    post_latitude_changed? or post_longitude_changed?
  end
  
  def set_marker_json
    self.marker_json = {:id => id.to_s, :lat_pos => post_latitude.to_s, :long_pos => post_longitude.to_s, 
                        :marker_id => "#{id}_#{default_category}", icon: '/wp-content/uploads/2014/11/chart.png', 
                        :group => "catgroup#{default_category}"}.to_json
    self.post_icon = build_post_icon unless post_icon.present?
    post_icon.attributes = {:post_title => post_title, :cat_id => default_category, :json => marker_json}
  end
end

class User < WPModel
  self.table_name  = :wp_users
  self.primary_key = :ID
  has_many :user_metas, :dependent => :destroy
end 

class UserMeta < WPModel
  self.table_name  = :wp_usermeta
  self.primary_key = :umeta_id
  belongs_to :user
end 

class TermRelationship < WPPublicModel
  self.table_name = 'wp_term_relationships'
  self.primary_key = :object_id
  belongs_to :object, :class => 'PostLocation'
end
