# python-weatherstation
Weather station : read bme280 and record to Postgresql database with R dashboard UI

Hardware requirements:
1. Raspberry pi
2. WIFI or Ethernet connection
3. BME280 sensor (connected to Raspberry pi via I2C)

Software requirements:
A. Raspberry pi setup
  1. Install Python3
  2. Install PIP
        
    sudo apt install python3-pip

  3. Install I2C tools

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
  1. Install the prerequsisites for building the psycopg2
  
    sudo apt install libpq-dev python3-dev

  2. Install psycopg2

    sudo pip3 install psycopg2
