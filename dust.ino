/* Grove - Dust Sensor Demo v1.0
 Interface to Shinyei Model PPD42NS Particle Sensor
 Program by Christopher Nafis 
 Written April 2012
 
 http://www.seeedstudio.com/depot/grove-dust-sensor-p-1050.html
 http://www.sca-shinyei.com/pdf/PPD42NS.pdf
 
 JST Pin 1 (Black Wire)  => Arduino GND
 JST Pin 3 (Red wire)    => Arduino 5VDC
 JST Pin 4 (Yellow wire) => Arduino Digital Pin 8
 */

int pin = 9;
unsigned long duration;
unsigned long starttime;
unsigned long sampletime_us = 30000000;//sampe 30s ;
unsigned long lowpulseoccupancy = 0;
unsigned long stoptime = 0; 
unsigned long pulses = 0;
float ratio = 0;
float concentration = 0;

#include "dht11.h"
dht11 DHT11;
#define DHT11PIN 2

void setup() {
  Serial.begin(115200);
  pinMode(pin,INPUT);
  digitalWrite(pin, HIGH);

  starttime = micros();//get the current time;
}

void loop() {
  duration = pulseIn(pin, LOW, sampletime_us);
  if(duration == 0) {
    duration = 0;
//    Serial.println("timeout");
  } else {
//    Serial.println("pulse");
  }
    

  pulses += 1;
  lowpulseoccupancy = lowpulseoccupancy+duration;
  stoptime = micros();

  if ((stoptime-starttime) >= sampletime_us)//if the sampel time == 30s
  {
    ratio = lowpulseoccupancy/(float)(stoptime-starttime)*100.0;  // Integer percentage 0=>100
    concentration = 1.1*pow(ratio,3)-3.8*pow(ratio,2)+520*ratio+0.62; // using spec sheet curve

   int chk = DHT11.read(DHT11PIN);

    Serial.print("[");    
    Serial.print(lowpulseoccupancy);    
    Serial.print(",");
    Serial.print((stoptime-starttime));
    Serial.print(",");
    Serial.print(ratio);
    Serial.print(",");
    Serial.print(concentration);
    Serial.print(",");
    Serial.print(pulses),
    Serial.print(",");    
    Serial.print((float)DHT11.humidity, 2);
    Serial.print(",");
    Serial.print((float)DHT11.temperature, 2);
    Serial.println("]");    

    lowpulseoccupancy = 0;
    starttime = micros();
    pulses = 0;
  }
}
