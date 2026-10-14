-- ============================================================================
-- Tiger Cloud: IoT Sensor Dataset Simulation & Time-Series Analytics
-- Challenge: Simulate an IoT sensor dataset for testing and development
-- ============================================================================

-- 1. Create Relational Metadata Table
-- Stores metadata about physical objects/devices (type, deployment location)
DROP TABLE IF EXISTS sensor_data CASCADE;
DROP TABLE IF EXISTS sensors CASCADE;

CREATE TABLE sensors (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50),
    location VARCHAR(50)
);

-- 2. Create Time-Series Measurements Table
CREATE TABLE sensor_data (
    time TIMESTAMPTZ NOT NULL,
    sensor_id INTEGER,
    temperature DOUBLE PRECISION,
    cpu DOUBLE PRECISION,
    FOREIGN KEY (sensor_id) REFERENCES sensors (id)
);

-- 3. Convert to TimescaleDB Hypertable
-- Partitions data by time for fast ingestion and query pruning
SELECT create_hypertable('sensor_data', 'time', if_not_exists => TRUE);

-- 4. Populate Sensor Relational Metadata
INSERT INTO sensors (type, location) VALUES 
('a', 'floor'), 
('a', 'ceiling'), 
('b', 'floor'), 
('b', 'ceiling');

-- 5. Simulate 24 Hours of Telemetry
-- Uses generate_series and random() to generate 5-minute interval metrics
INSERT INTO sensor_data (time, sensor_id, cpu, temperature) 
SELECT 
    time, 
    sensor_id, 
    random() AS cpu, 
    random() * 100 AS temperature 
FROM generate_series(now() - interval '24 hour', now(), interval '5 minute') AS g1(time), 
     generate_series(1, 4, 1) AS g2(sensor_id);
