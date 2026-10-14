# Simulating an IoT Sensor Dataset with Tiger Cloud

> **MLH Global Hack Week Challenge:** Simulate an IoT sensor dataset for testing and development with Tiger Cloud  
> **Sponsor / Technology:** Tiger Data & TimescaleDB  
> **Author:** SACHIN KUMAR SINGH (`sachin-alt`)  
> **Live Tiger Cloud Service:** [`cagg-analytics` (Service ID: `kiwbq9oup6`)](https://console.cloud.tigerdata.com/dashboard/services/kiwbq9oup6)

---

## 📌 Project Overview

Many real-world IoT environments (smart buildings, industrial sensors, datacenter infrastructure) require managing two distinct categories of data:
1. **Relational Metadata:** Infrequently changing contextual attributes about physical objects (e.g., sensor type, installation location, firmware version).
2. **Time-Series Telemetry:** High-frequency, append-heavy sequential data (e.g., temperature, CPU usage, voltage, power).

This project implements and tests a full IoT simulation pipeline on **Tiger Cloud**, combining standard relational tables with TimescaleDB **Hypertables** and native analytical SQL functions (`time_bucket`).

---

## ☁️ Tiger Cloud Service Details

* **Service Name:** `cagg-analytics`
* **Service ID:** `kiwbq9oup6`
* **Type:** TimescaleDB (PostgreSQL)
* **Region:** `us-east-1`
* **Console URL:** [https://console.cloud.tigerdata.com/dashboard/services/kiwbq9oup6](https://console.cloud.tigerdata.com/dashboard/services/kiwbq9oup6)
* **Status:** `READY`

---

## 🛠️ Step-by-Step Implementation

### 1. Relational Metadata & Hypertable Schema

```sql
-- Relational metadata table
CREATE TABLE sensors (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50),
    location VARCHAR(50)
);

-- Time-series telemetry table
CREATE TABLE sensor_data (
    time TIMESTAMPTZ NOT NULL,
    sensor_id INTEGER,
    temperature DOUBLE PRECISION,
    cpu DOUBLE PRECISION,
    FOREIGN KEY (sensor_id) REFERENCES sensors (id)
);

-- Convert to Timescale Hypertable
SELECT create_hypertable('sensor_data', 'time');
```

### 2. Inserting Metadata & Simulating 24-Hour Telemetry

```sql
-- Insert physical sensor positions
INSERT INTO sensors (type, location) VALUES 
('a', 'floor'), 
('a', 'ceiling'), 
('b', 'floor'), 
('b', 'ceiling');

-- Generate 24 hours of 5-minute interval metrics across 4 sensors
INSERT INTO sensor_data (time, sensor_id, cpu, temperature) 
SELECT 
    time, 
    sensor_id, 
    random() AS cpu, 
    random() * 100 AS temperature 
FROM generate_series(now() - interval '24 hour', now(), interval '5 minute') AS g1(time), 
     generate_series(1, 4, 1) AS g2(sensor_id);
```

---

## 📊 Analytical Queries & Live Output

### Query 1: Join Relational Metadata with Recent Readings

```sql
SELECT 
    sensor_data.time, 
    sensors.id AS sensor_id, 
    sensors.type, 
    sensors.location, 
    ROUND(sensor_data.temperature::numeric, 2) AS temp, 
    ROUND(sensor_data.cpu::numeric, 4) AS cpu 
FROM sensor_data 
JOIN sensors ON sensor_data.sensor_id = sensors.id 
ORDER BY time DESC 
LIMIT 5;
```

**Live Output:**
```
             time              | sensor_id | type | location | temp  |  cpu   
-------------------------------+-----------+------+----------+-------+--------
 2026-10-14 14:42:04.937187+00 |         1 | a    | floor    | 32.83 | 0.6484 
 2026-10-14 14:42:04.937187+00 |         2 | a    | ceiling  | 87.50 | 0.9881 
 2026-10-14 14:42:04.937187+00 |         3 | b    | floor    | 32.17 | 0.1453 
 2026-10-14 14:42:04.937187+00 |         4 | b    | ceiling  | 65.13 | 0.4185 
 2026-10-14 14:37:04.937187+00 |         1 | a    | floor    | 44.51 | 0.9697 
```

### Query 2: Time-Bucketed Aggregation by Sensor Location

```sql
SELECT 
    time_bucket('1 hour', time) AS hour, 
    sensors.location, 
    ROUND(AVG(temperature)::numeric, 2) AS avg_temp, 
    ROUND(AVG(cpu)::numeric, 4) AS avg_cpu 
FROM sensor_data 
JOIN sensors ON sensor_data.sensor_id = sensors.id 
GROUP BY hour, sensors.location 
ORDER BY hour DESC, sensors.location 
LIMIT 6;
```

**Live Output:**
```
          hour          | location | avg_temp | avg_cpu 
------------------------+----------+----------+---------
 2026-10-14 14:00:00+00 | ceiling  |    51.69 |  0.4614
 2026-10-14 14:00:00+00 | floor    |    44.22 |  0.4891
 2026-10-14 13:00:00+00 | ceiling  |    44.09 |  0.4692
 2026-10-14 13:00:00+00 | floor    |    55.28 |  0.4820
 2026-10-14 12:00:00+00 | ceiling  |    55.45 |  0.4770
 2026-10-14 12:00:00+00 | floor    |    61.98 |  0.4995
```

---

## 📂 Repository Contents

* [`schema.sql`](schema.sql): Complete SQL definitions for relational metadata, hypertable, and data generation.
* [`queries.sql`](queries.sql): Relational joins and time-bucket aggregation queries.
