require 'edge'
require 'benchmark'
require 'securerandom'
require 'optparse'

database_config = YAML.load_file(File.expand_path("../database.yml", __FILE__))
ActiveRecord::Base.establish_connection database_config["bench"]

class ActsAsForestRecord < ActiveRecord::Base
  acts_as_forest
end

def clean_database
  ActsAsForestRecord.delete_all
end

def vacuum_analyze
  ActiveRecord::Base.connection.execute "VACUUM ANALYZE acts_as_forest_records"
end
