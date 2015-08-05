DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS body_parts;

CREATE TABLE locations(
  id serial PRIMARY KEY,
  parent_id integer REFERENCES locations,
  name varchar NOT NULL,
  attrs json DEFAULT NULL -- include a column that does not have an operator defined that can be used with union
);

CREATE TABLE body_parts(
  id serial PRIMARY KEY,
  body_part_id integer REFERENCES body_parts -- something that uses a non-standard parent ID
);
