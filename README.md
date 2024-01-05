# python-weatherstation
Weather station : read bme280 and record to Postgresql database with R dashboard UI

## Objective and Scope:
Collects environmental data (Temperature, Humidity, Pressure) using BME280 sensors on Raspberry Pi.
Sends collected data to PostgreSQL database (ElephantSQL) periodically.
Supports multiple stations.


## Requirements and Constraints
Raspberry Pi hardware with BME280 I2C devices.
Required setup on raspberry pi (see Installation.md)
Interaction with PostgreSQL (ElephantSQL.com) database for data storage.
