import time
import requests
import RPi.GPIO as gpio
import datetime as dt
import csv
import calendar

pin = [7, 11, 13, 15]

status = [0, 0, 0, 0]
oncount = [0, 0, 0, 0]
offcount = [0, 0, 0, 0]
readout = [0, 0, 0, 0]

floorcode = 0

# Setup pins
gpio.setmode(gpio.BOARD)
for i in range(4):
    gpio.setup(pin[i], gpio.IN)


# Load floorcode from config file
with open('config.txt', 'r') as f:
    floorcode = f.read()
    floorcode = floorcode.strip()

t = dt.datetime.now() # Save the current time to a variable ('t')

while(True):
    statusChanged = False


    for i in range(4):
        readout[i] = gpio.input(pin[i])

    for i in range(4):
        if (readout[i] == 1):
            oncount[i] = 0
            offcount[i] += 1
        else:
            offcount[i] = 0
            oncount[i] += 1

        if (offcount[i] > 8):
            offcount[i] = 8

        if (oncount[i] > 8):
            oncount[i] = 8

        if (offcount[i] >= 8 and status[i] != 0):
            status[i] = 0
            offcount[i] = 0
            statusChanged = True
        elif (oncount[i] >= 8 and status[i] != 1):
            oncount[i] = 0
            status[i] = 1
            statusChanged = True
        elif (offcount[i] > 1 and status[i] == 1):
           status[i] = 2
           statusChanged = True
        elif (oncount[i] > 1 and status[i] == 0):
            status[i] = 2
            statusChanged = True

    res = ''.join(str(e) for e in status)

    
    delta = dt.datetime.now() - t
    if delta.seconds >= 5 * 60 or statusChanged: # update a new row every 5 minutes, or when status is changed
        print('Writing to log - ' + str(status))
        t = dt.datetime.now()  # update 't' variable to new time
    
        timestampObj = calendar.timegm(time.gmtime()) # for timestamp formatting
        timestamp = dt.datetime.fromtimestamp(timestampObj).isoformat()
        
        with open('logging.csv','a') as csvfile:
            writer = csv.writer(csvfile)

            # append a new row containing timestamp and status of 4 machines, statusChanged
            # example row: 0,1,2,0,True
            writer.writerow([timestamp,status[0],status[1],status[2],status[3],statusChanged])
            csvfile.close()
    
    if (statusChanged):
        print("change detected")
        print(res)
        requests.post("http://188.166.181.174:5000/api/update",
        data = {
            "floor":floorcode,
            "data":res
        })
        statusChanged = False

    time.sleep(0.15)