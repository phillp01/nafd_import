class SupplierMember < ActiveRecord::Base
  before_save :update_aggregate_fields
  
  def update_aggregate_fields
    self.rendered_name = [company_name, address_1, address_2, address_3, city, region, postcode, country].reject{|i| i.blank?}.join("<br />")
    self.rendered_contact = [
      [tel, "<i class='fa fa-phone'></i>Phone: #{tel}"], 
      [fax, "<i class='fa fa-fax'></i>Fax: #{fax}"], 
      [email, "<i class='fa fa-at'></i>Email: <a href='mailto:#{email}'>#{email}</a>"],
      [web_site, "<i class='fa fa-link'></i>Web: <a href='#{web_site}'>#{web_site}</a>"]
    ].map{|i| i[0].present? ? i[1] : nil}.compact.join("<br />")
  end

  def destroyed?
    destroyed_at.present?
  end
end

