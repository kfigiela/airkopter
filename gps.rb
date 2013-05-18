#!/usr/bin/env ruby

require 'serialport'
@sp = SerialPort.open("/dev/rfcomm0", 115200, 8, 1, SerialPort::NONE)
while(sentence = @sp.gets) do
  puts sentence 
end


