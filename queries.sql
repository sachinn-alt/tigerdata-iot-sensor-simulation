-- ============================================================================
-- Tiger Cloud: IoT Sensor Dataset Analytics & Queries
-- ============================================================================

-- Query 1: Join Relational Metadata with Recent Time-Series Telemetry
SELECT 
    sensor_data.time, 
    sensors.id AS sensor_id, 
    sensors.type, 
    sensors.location, 
    ROUND(sensor_data.temperature::numeric, 2) AS temperature, 
    ROUND(sensor_data.cpu::numeric, 4) AS cpu_usage
FROM sensor_data 
JOIN sensors ON sensor_data.sensor_id = sensors.id 
ORDER BY time DESC 
LIMIT 10;

-- Query 2: Time-Bucketed Aggregation by Sensor Location
-- Demonstrates hypertable chunk pruning and downsampling
SELECT 
    time_bucket('1 hour', time) AS hour, 
    sensors.location, 
    ROUND(AVG(temperature)::numeric, 2) AS avg_temperature, 
    ROUND(AVG(cpu)::numeric, 4) AS avg_cpu_usage,
    COUNT(*) AS readings_count
FROM sensor_data 
JOIN sensors ON sensor_data.sensor_id = sensors.id 
GROUP BY hour, sensors.location 
ORDER BY hour DESC, sensors.location 
LIMIT 10;
