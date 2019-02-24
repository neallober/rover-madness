#!/usr/bin/ruby

require 'socket'  # required to communicate with the monitoring station

# Set the station number below
station_number = "1"

# Connect to the monitoring station
server_address = "localhost"

# Pre-programmed MIFARE NFC chip id's below:
rover1  = "f7 9a 1f 01"
rover2  = "60 2f aa 55"
rover3  = "60 4e b1 55"
rover4  = "a0 5f b1 55"


# Enter the main loop of the program
while true
  output = `/home/pi/Software/working/nfc-pulse 2>/dev/null`

  outputstring = station_number

  if output.include?rover1
    puts "Rover 1 has reached this goal post!"
    outputstring += ",1"
  end

  if output.include?rover2
    puts "Rover 2 has reached this goal post!"
    outputstring += ",2"
  end

  if output.include?rover3
    puts "Rover 3 has reached this goal post!"
    outputstring += ",3"
  end

  if output.include?rover4
    puts "Rover 4 has reached this goal post!"
    outputstring += ",4"
  end

  # Open a socket connection to the monitoring station
  # and send the data that the rover has reached here
  if outputstring != station_number
    socket = TCPSocket.open( server_address, 2000 )
    socket.puts outputstring
    socket.read(2)
  end

  # sleep for two seconds before checking again
  sleep 2
end

