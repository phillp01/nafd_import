#!/usr/bin/env ruby
require_relative 'setup'

SupplierMember.where.not(:email => nil).map do |member|
  email = member.email.strip
  if user = User.find_by(:user_email => email)
    user.user_metas.find_by(:meta_key => '_nafd_member').try(:destroy)
    user.user_metas.find_or_create_by(:meta_key => "_nafd_member_#{member.member_id}", :meta_value => "_nafd_branch_#{member.branch_id}")
    puts "user_id: #{user.ID}, member_id: #{member.member_id}, branch_id: #{member.branch_id}"
  end
end
