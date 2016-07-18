require 'edge'
require 'yaml'

require 'rspec'

database_config = YAML.load_file(File.expand_path("../database.yml", __FILE__))
ActiveRecord::Base.establish_connection database_config["test"]

RSpec.configure do |config|
  config.before(:all) do |example|
    ActiveRecord::Base.connection.execute <<-SQL
      truncate body_parts;
      truncate locations;
    SQL
  end

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.call
      raise ActiveRecord::Rollback
    end
  end
end
