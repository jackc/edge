require 'benchmark_helper'

options = {}
optparse = OptionParser.new do |opts|
  options[:num_trees] = 50
  opts.on '-t NUM', '--trees NUM', Integer, 'Number of trees to create' do |n|
    options[:num_trees] = n
  end
  
  options[:depth] = 3
  opts.on '-d NUM', '--depth NUM', Integer, 'Depth of trees' do |n|
    options[:depth] = n
  end
  
  options[:num_children] = 10
  opts.on '-c NUM', '--children NUM', Integer, 'Number of children per node' do |n|
    options[:num_children] = n
  end
  
  options[:payload_size] = 16
  opts.on '-p NUM', '--payload NUM', Integer, 'Characters of payload per node' do |n|
    options[:payload_size] = n
  end
end

optparse.parse!

NUM_TREES = options[:num_trees]
DEPTH = options[:depth]
NUM_CHILDREN = options[:num_children]
PAYLOAD_SIZE = options[:payload_size]


def create_forest_tree(current_depth = 1, parent = nil)
  node = ActsAsForestRecord.create! :parent => parent, :payload => "z" * PAYLOAD_SIZE
  unless current_depth == DEPTH
    NUM_CHILDREN.times { create_forest_tree current_depth + 1, node }
  end
  node
end

clean_database
ActsAsForestRecord.transaction do
  NUM_TREES.times { create_forest_tree }
end
vacuum_analyze

puts "Trees: #{NUM_TREES}"
puts "Depth: #{DEPTH}" 
puts "Children per node: #{NUM_CHILDREN}"
puts "Payload characters per node: #{PAYLOAD_SIZE}"
puts "Descendants per tree: #{ActsAsForestRecord.find_tree(ActsAsForestRecord.root.first.id).descendants.size}"
puts "Total records: #{ActsAsForestRecord.count}"


Benchmark.bm(40) do |x|
  load_entire_forest_times = 10
  x.report("Load entire forest #{load_entire_forest_times} times") do
    load_entire_forest_times.times do
      ActsAsForestRecord.find_forest
    end
  end
  
  load_one_tree_times = 100
  first_tree_id = ActsAsForestRecord.root.first.id
  x.report("Load one tree #{load_one_tree_times} times") do
    load_one_tree_times.times do
      ActsAsForestRecord.find_tree first_tree_id
    end
  end
end
