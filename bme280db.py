
'''----------------------------------------------------------------------------------------------------
RESOURCES:
    https://www.raspberrypi-spy.co.uk/2016/07/using-bme280-i2c-temperature-pressure-sensor-in-python/
----------------------------------------------------------------------------------------------------'''
import bme280
import time
import datetime
import psycopg2
from psycopg2 import Error

def DBconnect():
    global connection
    
    connection = psycopg2.connect(user="bzfjdjpk",
                                  password="GQS3YNEdkvfl6oj8zo2-KHrQ0U1fSKch",
                                  host="tiny.db.elephantsql.com",
                                  port="5432",
                                  database="bzfjdjpk")    

def DBinsert(now, temp, press, humid):
    # Executing a SQL query to insert data into  table
    
    # string management alternatives
    #insert_query = f"INSERT INTO station1 (calendar, Temperature, Pressure) VALUES ({now},{temp},{press})"
    #insert_query = "INSERT INTO station1 (calendar, Temperature, Pressure) VALUES ({},{},{})".format(now, temp, press)
    insert_query = """ INSERT INTO station1 (calendar, Temperature, Pressure, Humidity) VALUES (%s, %s, %s, %s)"""

    item_tuple = (now, temp, press, humid)
    cursor.execute(insert_query, item_tuple)
    connection.commit()

def DBread():
    # Fetch result
    cursor.execute("SELECT * from station1 ORDER BY calendar DESC LIMIT 1")
    record = cursor.fetchall()    
    print("1 Record inserted successfully")
    print("Result ", record)

try:
    DBconnect()
    cursor = connection.cursor()
    now = datetime.datetime.now()
    temperature,pressure,humidity = bme280.readBME280All()    
    DBinsert(now, temperature, pressure, humidity)
    DBread()

except (Exception, psycopg2.Error) as error:
    print("Error while connecting to PostgreSQL", error)
finally:
    if connection:
        cursor.close()
        connection.close()
        print("PostgreSQL connection is closed")