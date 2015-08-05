#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new
task :default => :spec

namespace :db do
  desc 'bootstrap database'
  task :setup do
    sh "createdb edge_test || true"
    sh "psql edge_test < spec/database_structure.sql"
  end
end
