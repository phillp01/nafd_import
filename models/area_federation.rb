class AreaFederation < ActiveRecord::Base
  before_save :update_aggregate_fields

  def update_aggregate_fields
    self.rendered_name = [name, secretary].reject{|i| i.blank?}.join("<br />\n")
    self.rendered_address = [address_1, address_2, address_3, address_4, postcode, country].reject{|i| i.blank?}.join("<br />\n")
    self.rendered_contact = [
      [tel, "<i class='fa fa-phone'></i>Phone:&nbsp;#{tel}"],
      [mobile, "<i class='fa fa-phone'></i>Mobile:&nbsp;#{mobile}"],
      [fax, "<i class='fa fa-fax'></i>Fax:&nbsp;#{fax}"],
      [email, "<i class='fa fa-at'></i>Email:&nbsp;<a href='mailto:#{email}'>#{email}</a>"]
    ].map{|i| i[0].blank? ? nil : i[1]}.compact.join("<br />")
  end
end

