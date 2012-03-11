DROP TABLE IF EXISTS locations;

CREATE TABLE locations(
  id serial PRIMARY KEY,
  parent_id integer REFERENCES locations,
  name varchar NOT NULL
);
