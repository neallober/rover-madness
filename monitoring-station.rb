require 'socket'

server = TCPServer.new 2000

# Configure the numbers of stations and rovers
numstations = 4
numrovers   = 3

# Initialize a 2 dimensional array with 4 rows and 3 columns 
# to track rover progress. Then initialize all to false.
$s_arrsize = numstations + 1
$r_arrsize = numrovers + 1
$rovers = Array.new($s_arrsize) { Array.new($r_arrsize) }
$s_arrsize.times do |i|
  $r_arrsize.times do |j|
    $rovers[i][j] = false
  end
end



# -------------------------------------------------
# Helper function that writes the current results
# to the html file.
# -------------------------------------------------
def update_html_file
  html = File.read("./statuspage-template.html");
  success_fragment = File.read("./statuspage-fragment-success.html");
  failure_fragment = File.read("./statuspage-fragment-failure.html");

  # Loop through the rovers 2d array and replace the
  # {XX} placeholders with actual rover results
  $s_arrsize.times do |i|
    $r_arrsize.times do |j|
      #p "Station #{i}, Rover #{j} = #{$rovers[i][j]}" unless (i == 0 or j == 0)
      # Replace the template placeholder with the desired code
      string_to_find = "{" + i.to_s + j.to_s + "}"
      if $rovers[i][j]
        html.sub! string_to_find, success_fragment
      else
        html.sub! string_to_find, failure_fragment
      end
    end
  end

  File.open("./monitor.html", "w") { |file| file.write(html) }
end # update_html_file




loop do

  # -------------------------------------------------
  # Wait for a client connection on port 2000
  # -------------------------------------------------
  client = server.accept
  # Wait to read a message from the client
  theinput = client.gets

  # confirm back to the client
  client.puts "OK"

  # close the client connection
  client.close

  # -------------------------------------------------
  # Process the data from the client into the 2d array
  # -------------------------------------------------
  station_number = theinput[0]  # The first character is the station number
  rover_number   = theinput[2]  # The third character is the rover number
  $rovers[station_number.to_i][rover_number.to_i] = true


  # -------------------------------------------------
  # Update the HTML file with the rovers' progress
  # -------------------------------------------------
  update_html_file
end
