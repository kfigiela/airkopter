#!/usr/bin/env ruby
# encoding: utf-8

require 'serialport'
require 'rest-client'
require 'date'
require 'json'

gps = {
  lat: nil,
  lon: nil,
  time: nil,
  fix: nil,
  alt: nil
}

gpsThread = Thread.new do 
  sp = SerialPort.open("/dev/rfcomm0", 115200, 8, 1, SerialPort::NONE)

  regexp  = /\$GPGGA,(\d+(?:\.\d+)?),(\d+(?:\.\d+)?),([NS]),(\d+(?:\.\d+)?),([EW]),\d,\d+,\d+(?:\.\d+)?,(\d+(?:\.\d+)?)/  
  coordregex = /(\d+)(\d\d(?:\.\d+)?)/
  while(sentence = sp.gets) do
    matches     = regexp.match sentence
    if matches
      gps[:time]    = matches[1]
      gps[:fix]     = (matches[2] == "A")
      lat = coordregex.match matches[2]
      lon = coordregex.match matches[4]

      gps[:lat]     = (lat[1].to_i + lat[2].to_f/60.0)  * (if matches[3] == "N" then 1 else -1 end)
      gps[:lon]     = (lon[1].to_i + lon[2].to_f/60.0) * (if matches[5] == "E" then 1 else -1 end)
      gps[:alt]     = matches[6].to_f
#      p gps
    else 
#	p sentence
    end
    p gps
  end
end


flight = JSON.parse (RestClient.post 'http://airkopter.herokuapp.com/flights', :accept => :json)
flight_id = flight["id"]


#dustThread = Thread.new do 
  sp = SerialPort.open("/dev/ttyACM0", 115200, 8, 1, SerialPort::NONE)

  File.open("dust.log", "a") do |f|
    while(sentence = sp.gets) do
      puts sentence
      regexp = /^\[(\d+),(\d+),(\d+(?:\.\d+)?),(\d+(?:\.\d+)?),(\d+),(\d+(?:\.\d+)?),(\d+(?:\.\d+)?)\]/
      matches = regexp.match sentence
      unless matches
        puts "Couldn't parse: [#{sentence}]"
      else
        result = {timestamp: DateTime.now, ratio: matches[3].to_f, concentration: matches[4].to_f, gps: gps, sensordata: sentence, humidity: matches[6].to_f, temperature: matches[7].to_f}
        p result
        f.puts result.to_json
        req_data = {data: {timestamp: DateTime.now, ratio: matches[3].to_f, concentration: matches[4].to_f, lat: gps[:lat], lon: gps[:lon], humidity: matches[6].to_f, temperature: matches[7].to_f, altitude: gps[:alt]}}
	begin
	  RestClient.put "http://airkopter.herokuapp.com/flights/#{flight_id}", req_data, content_type: :json, accept: :json
        rescue Exception => e
	  puts "Couldn't save data to webserver"
        end
      end
    end
  end
#end

#gpsThread.join
#dustThread.join

