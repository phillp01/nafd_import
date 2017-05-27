require 'rubygems'
require 'bundler/setup'
require 'erb'
require 'yaml'
require 'active_record'
require 'active_mdb'
require 'standalone_migrations'
require 'wpcli'
require 'csv'
require 'comma'
require 'geocoder'
require 'geocoder/models/active_record'

config = YAML.load(ERB.new(File.read('db/config.yml')).result).with_indifferent_access

puts config.inspect
puts " GAP "
puts config[:geocoders]

Geocoder.configure(config[:geocoders])

ActiveRecord::Base.configurations = config[:db]
ActiveRecord::Base.establish_connection(:development)
class WPModel < ActiveRecord::Base
  self.abstract_class = true
end
WPModel.establish_connection(:members_production)

class WPPublicModel < ActiveRecord::Base
  self.abstract_class = true
end
WPPublicModel.establish_connection(:public_production)

require_relative 'models/local_association'
require_relative 'models/member'
require_relative 'models/area_federation'
require_relative 'models/supplier_member'
require_relative 'models/wordpress'
