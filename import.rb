#!/usr/bin/env ruby
require_relative 'setup'

$stderr.puts "********"
$stderr.puts "** Import on #{Time.now}"
$stderr.puts "********"
# Setup connection for transient datastore
db = ActiveRecord::Base.configurations[:development]
mysql_command = "mysql --user=#{db[:username]} --password=#{db[:password]} --host=#{db[:host]} #{db[:database]}"

time_string = Time.now.strftime("%Y-%m-%d")
mdb_filename   = 'mdb/NAFD_Web_DB.mdb'
mdb_created_at = File.ctime(mdb_filename)
is_remote = (`uname`.strip == 'Linux')

if is_remote && File.exist?('../incoming/NAFD_Web_DB.mdb')
  $stderr.puts "moving in new mdb"
  `mv mdb/NAFD_Web_DB.mdb mdb/_old/NAFD_Web_DB-#{time_string}.mdb`
  `mv ../incoming/NAFD_Web_DB.mdb mdb/`
end

$stderr.puts "deleting existing transient data"
DboInspection.delete_all
DboMember.delete_all
# DboMemberName.delete_all

# Export Access data into MySQL and fix formatting issues within the output stream.
$stderr.puts "importing mdb -> dbo_inspections"
`mdb-export -D '%Y-%m-%d %H:%M:%S' -I mysql mdb/NAFD_Web_DB.mdb dbo_inspections | LC_ALL=C tr -cd '\11\12\15\40-\176' | #{mysql_command}`
$stderr.puts "importing mdb -> dbo_members"
`mdb-export -D '%Y-%m-%d %H:%M:%S' -I mysql mdb/NAFD_Web_DB.mdb dbo_members | LC_ALL=C tr -cd '\11\12\15\40-\176' | #{mysql_command}`
$stderr.puts "importing mdb -> dbo_MemberNames"
`mdb-export -D '%Y-%m-%d %H:%M:%S' -I mysql mdb/NAFD_Web_DB.mdb dbo_MemberNames | LC_ALL=C tr -cd '\11\12\15\40-\176' | #{mysql_command}`

DboMember.where(:county => nil).update_all(:county => '')
DboMember.where(:postcode => nil).update_all(:postcode => '')
DboMember.where(:countrycode => nil).update_all(:countrycode => '')
Member.where(:city => nil).update_all(:city => '')
Member.where(:region => nil).update_all(:region => '')
Member.where(:postcode => nil).update_all(:postcode => '')

$stderr.puts " ** sorting out all data in transient developemnt database"
`bundle exec rake db:seed`

$stderr.puts " ** userFudge"
require_relative 'import_users'

$stderr.puts " ** geodirFudge"
require_relative 'import_geodir'
