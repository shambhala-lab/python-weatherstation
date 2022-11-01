# python-weatherstation
Weather station : read bme280 and record to Postgresql database with R dashboard UI

Hardware requirements:
1. Raspberry pi
2. WIFI or Ethernet connection
3. BME280 sensor (connected to Raspberry pi via I2C)

Software requirements:
A. Raspberry pi setup
  1. Python3 installed
  2. Pip install
        
    sudo apt install python3-pip

  3. I2C install

    sudo apt install -y i2c-tools python3-smbus
        
  4. Raspi-config -> enable I2C
  5. Verify I2C address of BME280 connection
  
    sudo i2cdetect -y 1

  6. Test BME280 functionality by running python script bme280.py

    python3 bme280.py
     >>> Temperature :  26.31 C
     >>> Pressure :  966.0570039298742 hPa
     >>> Humidity :  42.01362428945469 %    
    
B. Postgresql DB setup
  1. sdfasdf
  2. sdfsadf

