# Edge

Edge provides graph functionality to ActiveRecord using recursive common table
expressions. It has only been tested with PostgreSQL, but it uses Arel for
SQL generation so it should work with any database and adapter that support
recursive CTEs.

acts_as_forest enables an entire tree or even an entire forest of trees to
be loaded in a single query. All parent and children associations are
preloaded.

## Installation

Add this line to your application's Gemfile:

    gem 'edge'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install edge

## Usage

acts_as_forest adds tree / multi-tree functionality. All it needs a parent_id
column. This can be overridden by passing a :foreign_key option to
acts_as_forest.

    class Location < ActiveRecord::Base
      acts_as_forest :order => "name"
    end

    usa = Location.create! :name => "USA"
    illinois = usa.children.create! :name => "Illinois"
    chicago = illinois.children.create! :name => "Chicago"
    indiana = usa.children.create! :name => "Indiana"
    canada = Location.create! :name => "Canada"
    british_columbia = canada.children.create! :name => "British Columbia"

    Location.root.all # [usa, canada]
    Location.find_forest # [usa, canada] with all children and parents preloaded
    Location.find_tree usa.id # load a single tree.

It also provides the with_descendants scope to get all currently selected
nodes and all their descendents. It can be chained after where scopes, but
must not be used after any other type of scope.

    Location.where(name: "Illinois").with_descendants.all # [illinois, chicago]

## Benchmarks

Edge includes a performance benchmarks. You can create test forests with a
configurable number of trees, depth, number of children per node, and
size of payload per node.

    jack@moya:~/work/edge$ ruby -I lib -I bench bench/forest_find.rb --help
    Usage: forest_find [options]
        -t, --trees NUM                  Number of trees to create
        -d, --depth NUM                  Depth of trees
        -c, --children NUM               Number of children per node
        -p, --payload NUM                Characters of payload per node

Even on slower machines entire trees can be loaded quickly.

    jack@moya:~/work/edge$ ruby -I lib -I bench bench/forest_find.rb
    Trees: 50
    Depth: 3
    Children per node: 10
    Payload characters per node: 16
    Descendants per tree: 110
    Total records: 5550
                                                   user     system      total        real
    Load entire forest 10 times                4.260000   0.010000   4.270000 (  4.422442)
    Load one tree 100 times                    0.830000   0.040000   0.870000 (  0.984642)

### Running the benchmarks

1. Create a database such as edge_bench.
2. Configure bench/database.yml to connect to it.
3. Load bench/database_structure.sql into your bench database.
4. Run benchmark scripts from root of gem directory (remember to pass ruby
   the include paths for lib and bench)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT
