DROP TABLE IF EXISTS acts_as_forest_records;

CREATE TABLE acts_as_forest_records(
  id serial PRIMARY KEY,
  parent_id integer REFERENCES acts_as_forest_records,
  payload varchar NOT NULL
);

CREATE INDEX ON acts_as_forest_records (parent_id);
