#!/usr/bin/env ruby
require_relative '../setup.rb'
require_relative '../models/access_tables.rb'

# Office only may not be on list in future.

puts "*  Starting AreaFederations #{Time.now}"
# AreaFederation.destroy_all
NafdAreaSecretary.load_it_all
puts " * Done AreaFederations #{Time.now}"

puts "*  Starting LocalAssociations #{Time.now}"
# LocalAssociation.destroy_all
NafdLocalSecretary.load_it_all
puts " * Done LocalAssociations #{Time.now}"

puts "*  About to memberfudge #{Time.now}"
seen_at = Time.now
DboMember.all.each do |nm|
  master_branch = if nm.read_attribute('BranchID') == 0
    nm
  else
    DboMember.unscoped.find_by("MemberID = ? AND BranchID = 0", nm.read_attribute('MemberID'))
  end
  master_grade = master_branch.try(:read_attribute, 'Grade') || 1

  m = Member.unscoped.find_or_initialize_by(:member_id => nm.read_attribute('MemberID'), 
                                            :branch_id => nm.read_attribute('BranchID'))
  
  
  # puts " ** Member: #{m.member_id}:#{m.branch_id}:#{nm.read_attribute 'company_name'}: master_grade: #{master_grade}"
  if master_grade and (master_grade == 30 or master_grade == 51)
    if m.persisted?
      $stderr.puts "Member #{m.member_id}:#{m.branch_id} => Supplier (#{nm.read_attribute('CompanyName')})"
      m.destroy
    end
    
    m = SupplierMember.unscoped.find_or_initialize_by(:member_id => nm.read_attribute('MemberID'), 
                                                      :branch_id => nm.read_attribute('BranchID'))
    if nm.IsActive
      m = nm.import_as_supplier(m, master_grade)
      puts "Supplier Updated: #{m.id}: #{m.company_name}, :changes? #{m.changes.inspect}"
    elsif m.persisted? and not m.destroyed_at?
      $stderr.puts "Supplier Destroyed: #{m.id}: #{m.company_name}"
      m.update_attributes(:destroyed_at => Time.now)
    end
  else
    if nm.IsActive
      m = nm.import_as_member(m, master_grade)
      puts "Member Updated: #{m.id}: #{m.last_status}: #{m.company_name}, :changes? #{m.changes.inspect}"
    elsif m.persisted? and (not m.destroyed_at? or m.last_status != 'DELETED')
      $stderr.puts "Member Destroyed: #{m.id}: #{m.last_status}: #{m.company_name}"
      m.update_attributes(:destroyed_at => Time.now, :last_status => 'DELETED')
    end
  end

  # if m.persisted?
  #   m.seen_at = seen_at
  #   m.save(validate: false)
  # end
end
