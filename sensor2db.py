import time
import datetime
import psycopg2
from bmp280 import BMP280
from psycopg2 import Error

def DBconnect():
    global connection
    
    connection = psycopg2.connect(user="bzfjdjpk",
                                  password="GQS3YNEdkvfl6oj8zo2-KHrQ0U1fSKch",
                                  host="tiny.db.elephantsql.com",
                                  port="5432",
                                  database="bzfjdjpk")    

def DBinsert(now, temp, press):
    # Executing a SQL query to insert data into  table
    
    # string management varieties
    #insert_query = f"INSERT INTO station1 (calendar, Temperature, Pressure) VALUES ({now},{temp},{press})"
    #insert_query = "INSERT INTO station1 (calendar, Temperature, Pressure) VALUES ({},{},{})".format(now, temp, press)
    insert_query = """ INSERT INTO station1 (calendar, Temperature, Pressure) VALUES (%s, %s, %s)"""

    item_tuple = (now, temp, press)
    cursor.execute(insert_query, item_tuple)

    #cursor.execute(insert_query)
    connection.commit()

def DBread():
    # Fetch result
    cursor.execute("SELECT * from station1 ORDER BY calendar DESC LIMIT 1")
    record = cursor.fetchall()    
    print("1 Record inserted successfully")
    print("Result ", record)

# Unknown part from BMP280 reading
try:
    from smbus2 import SMBus
except ImportError:
    from smbus import SMBus

# Initialise the BMP280
bus = SMBus(1)
bmp280 = BMP280(i2c_dev=bus)

try:
    DBconnect()
    cursor = connection.cursor()
    now = datetime.datetime.now()    
    temp = bmp280.get_temperature()
    press = bmp280.get_pressure()    
    DBinsert(now, temp, press)
    DBread()

except (Exception, psycopg2.Error) as error:
    print("Error while connecting to PostgreSQL", error)
finally:
    if connection:
        cursor.close()
        connection.close()
        print("PostgreSQL connection is closed")        

# while True:
    # temperature = bmp280.get_temperature()
    # pressure = bmp280.get_pressure()
    # print('{:05.2f} C {:05.2f} hPa'.format(temperature, pressure))
    # time.sleep(30)        