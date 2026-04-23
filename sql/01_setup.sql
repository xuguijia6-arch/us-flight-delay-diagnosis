CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS clean;
CREATE SCHEMA IF NOT EXISTS mart;

DROP TABLE IF EXISTS raw.test_connection;

CREATE TABLE raw.test_connection (
    id SERIAL PRIMARY KEY,
    project_name TEXT NOT NULL,
    db_name TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO raw.test_connection (project_name, db_name, status)
VALUES ('US Flight Delay Diagnosis System', 'flight_delay_lab', 'postgres_ready');

SELECT * FROM raw.test_connection;