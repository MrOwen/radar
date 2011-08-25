$LOAD_PATH.unshift(File.expand_path("../app/helpers"))
$LOAD_PATH.unshift(File.expand_path("../app/controllers"))
$LOAD_PATH.unshift(File.expand_path("../app/models"))
$LOAD_PATH.unshift(File.expand_path("../config"))
require "imports_helper.rb"
require "environment"
require "CSV"
gem "actionpack", "=3.0.6"
require "action_pack"
gem "activerecord", "=3.0.6"
require "active_record"
gem "activemodel", "=3.0.6"
require "active_model"
gem "activeresource", "=3.0.6"
require "active_resource"
require "building.rb"
gem "ruby-oci8", ">=2.0.4"
require "oci8"
require "activerecord-oracle_enhanced-adapter"
require "YAML"

configurations = YAML::load(File.open("../config/database.yml"))
database=nil

if ["development","production","test"].include?(ARGV.first)
  database = configurations[ARGV.first]
else
  database = configurations["development"]
end

ActiveRecord::Base.establish_connection(
  :adapter  => database["adapter"],
  :database => database["database"],
  :username => database["username"],
  :password => database["password"],
  :host     => database["host"])

lines = ImportsHelper.parse_csv_file(File.expand_path("./shradar.csv"))
lines.shift
print "Import #{lines.size} records"
scnt = ImportsHelper.load_students(lines)
puts "Successfully imported #{scnt} records. #{lines.size-scnt} failures."
puts ImportsHelper::Helpers.stats
puts "ERROR MESSAGES:"
puts ImportsHelper::Helpers.error_messages