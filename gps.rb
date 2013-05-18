#!/usr/bin/env ruby
# encoding: utf-8

require 'serialport'
#require 'pp'
require 'date'
require 'json'

gps = {
  lat: nil,
  lon: nil,
  time: nil,
  fix: nil
}

gpsThread = Thread.new do 
  sp = SerialPort.open("/dev/rfcomm0", 115200, 8, 1, SerialPort::NONE)
  regexp  = /\$GPRMC,(\d+(?:\.\d+)?),([AV]),(\d+(?:\.\d+)?),([NS]),(\d+(?:\.\d+)?),([EW]),(\d+(?:\.\d+)?)/  

  while(sentence = sp.gets) do
    matches     = regexp.match sentence
    if matches
      gps[:time]    = matches[1]
      gps[:fix]     = (matches[2] == "A")
      gps[:lat]     = matches[3].to_f * (if matches[4] == "N" then 1 else -1 end)/100.0
      gps[:lon]     = matches[5].to_f * (if matches[4] == "E" then 1 else -1 end)/100.0
      p gps
    end
  end
end


#dustThread = Thread.new do 
  sp = SerialPort.open("/dev/ttyACM0", 115200, 8, 1, SerialPort::NONE)

  File.open("dust.log", "a") do |f|
    while(sentence = sp.gets) do
      puts sentence
      regexp = /^(\d+),(\d+),(\d+(?:\.\d+)?),(\d+(?:\.\d+)?),(\d+)/
      matches = regexp.match sentence
      unless matches
        puts "DUPA: [#{sentence}]"
      else
        result = {date: DateTime.now, ratio: matches[3], concentration: matches[4], gps: gps, sensordata: sentence}
        p result
        f.puts result.to_json
      end
    end
  end
#end

#gpsThread.join
#dustThread.join

