# 0.6.1 (February 20, 2021)

* Add Ruby 3 compatibility (Martins Polakovs)

# 0.6.0 (December 13, 2018)

* Fix usage when table name includes schema
* Drop Rails 4.x support

# 0.5.1 (August 4, 2017)

* Allow use of 'optional' option for belongs_to (Yuji Yaginuma)

# 0.5.0 (May 14, 2016)

* Add Rails 5.0 support
* Drop Rails 4.0 support
* Replace using internal arel with SQL string building

# 0.4.4 (January 29, 2016)

* Fix JRuby compatibility (jackc)

# 0.4.3 (October 23, 2015)

* Allow dependent option to acts_as_forest (WANG QUANG)

# 0.4.2 (May 21, 2015)

* Fixed premature SQL-ization that could result in PG protocol violation errors (Neil E. Pearson)
* Require Rails 4.0+
* Document ancestors method (science)

# 0.4.1 (January 15, 2015)

* Include rake as development dependency
* Fix for not passing string to belongs_to class_name (davekaro)

# 0.4.0 (December 23, 2014)

* Fix failure with bind_values
* Fix README typos (y-yagi)
* Improve performance by using flat_map (TheKidCoder)

# 0.3.2 (March 1, 2014)

* Set inverse_of on parent and children associations (Systho)

# 0.3.1 (February 7, 2014)

* Allow includes and with_descendents to work together (Systho)

# 0.3.0 (December 17, 2013)

* Rails 4 support
* Fix for incomparable column types

# 0.2.1 (March 6, 2013)

* Fix: acts_as_forest survives multiple calls

# 0.2.0 (February 22, 2013)

* Added with_descendents

# 0.1.0 (March 11, 2012)

* Initial release
