import bme280
  
temperature,pressure,humidity = bme280.readBME280All()
 
print("Temperature : ", temperature, "C")
print("Pressure : ", pressure, "hPa")
print("Humidity : ", humidity, "%")