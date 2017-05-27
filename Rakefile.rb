require 'bundler/setup'
require 'yaml'
require 'active_record'
require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks

puts "hello"

# include R
# DatabaseTasks = Object.new

root = File.dirname(__FILE__)
db_dir = File.join(root, 'db')
config_dir = File.join(root, 'db')
env = ENV['ENV'] || :development
database_configuration = YAML.load(File.read(File.join(config_dir, 'config.yml')))

task :environment do
  ActiveRecord::Base.configurations = database_configuration
  ActiveRecord::Base.establish_connection env
end

load 'active_record/railties/databases.rake'
