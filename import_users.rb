#!/usr/bin/ruby2.2
# require_relative 'setup'

class UserNotFound < StandardError; end
class UserShouldDelete < StandardError; end

wp = Wpcli::Client.new "/home/members/public_html"

def log(message, member, user = nil, user_meta = nil)
  str = " * #{message}: member_id: #{member.member_id}, branch_id: #{member.branch_id}"
  str += ", wp.user_id: #{user.ID}" if user.present?
  str += ", wp.user_meta: #{user_meta.umeta_id}" if user_meta.present?
  if user and user.user_email != member.email
    str += ", m: #{member.email} => u: #{user.user_email}"
  else
    str += ", m: #{member.email}"
  end
  puts str
end

def meta_count_for(user)
  user.user_metas.where('meta_key like ?', "_nafd_member_%").count
end

def remove_user_for(member, user, user_meta)
  user_meta.destroy
  email = member.email.try(:strip)
  log 'removed_user_meta', member, user, user_meta
  if meta_count_for(user) == 0
    wp = Wpcli::Client.new "/home/members/public_html"
    wp.run "user delete \"#{email}\" --reassign=1"
    log 'removed_user', member, user, user_meta
  end
end

def create_user_meta_for(member, user)
  log 'create_user_meta_for', member, user
  user.user_metas.find_or_create_by(:meta_key => "_nafd_member_#{member.member_id}", :meta_value  => "_nafd_branch_#{member.branch_id}")
end

def create_user_for(member)
  log 'create_user_for', member
  email = member.email.try(:strip)
  user = User.find_by(:user_email => email)
  if user.present?
    create_user_meta_for(member, user)
    return
  end
  wp = Wpcli::Client.new "/home/members/public_html"
  ret = wp.run "user create \"#{email}\" \"#{email}\" --display_name=\"#{email}\""
  if $?.to_i == 0
    user = User.find_by(:user_email => email)
    create_user_meta_for(member, user)
  end
end

def update_user_email_for(member, user, user_meta)
  log 'update_user_email_for', member, user, user_meta
  remove_user_for(member, user, user_meta)
  create_user_for(member)
end

def update_user_for(member, user, user_meta)
  # log 'update_user_for', member, user, user_meta
end

def check_member(member)
  begin
    email = member.email.try(:strip)
    user_meta = UserMeta.find_by(:meta_key => "_nafd_member_#{member.member_id}", :meta_value  => "_nafd_branch_#{member.branch_id}")
    user = user_meta.try(:user) 
    if user.blank? and email.present?
      User.find_by(:user_email => email)
    end
    
    case
    when (user.present? and user_meta.present? and (member.destroyed_at? or email.blank?))
     remove_user_for(member, user, user_meta)
    when (user.present? and user_meta.blank? and not member.destroyed_at? and email.present?)
      create_user_meta_for(member, user)
    when (user.blank? and not member.destroyed_at? and email.present?)
      create_user_for(member)
    when (user.present? and user_meta.present? and user.user_email.downcase != email.try(:downcase) and not member.destroyed_at? and email.present?)
      update_user_email_for(member, user, user_meta)
    when (user.present? and user_meta.present? and not member.destroyed_at? and email.present?)
      update_user_for(member, user, user_meta)
    end
  end
end

$stderr.puts " ** users from memberFudge"
Member.unscoped.all.map do |member|
  check_member(member)
end

$stderr.puts " ** users from supplierMemberFudge"
SupplierMember.unscoped.all.map do |member|
  check_member(member)
end
