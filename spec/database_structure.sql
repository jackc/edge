DROP TABLE IF EXISTS locations;

CREATE TABLE locations(
  id serial PRIMARY KEY,
  parent_id integer REFERENCES locations,
  name varchar NOT NULL,
  attrs json DEFAULT NULL -- include a column that does not have an operator defined that can be used with union
);
