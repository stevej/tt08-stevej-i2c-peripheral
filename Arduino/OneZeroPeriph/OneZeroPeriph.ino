/**
 * Test code for stevej's tinytapeout 08 i2c.
 * I2C Master for requesting a zero-one byte from a custom
 * I2C peripheral at 0x55.
 *
 */

#include <Wire.h>

byte i2c_rcv;             // data received from I2C bus
unsigned long time_start; // start time in milliseconds
int stat_LED;             // status of LED: 1 = ON, 0 = OFF

void setup()
{
    Wire.begin(); // join I2C bus as the master

    i2c_rcv = 255;
    time_start = millis();
    stat_LED = 0;

    pinMode(13, OUTPUT);
}

void loop()
{
    Wire.beginTransmission(0x55);
    Wire.endTransmission();

    Wire.requestFrom(0x55, 1);
    if (Wire.available())
    {
        i2c_rcv = Wire.read();
    }
    Serial.print(i2c_rcv, HEX);

    // blink an LED to show that we're alive.
    if ((millis() - time_start) > (1000 * (float)(i2c_rcv / 255)))
    {
        stat_LED = !stat_LED;
        time_start = millis();
    }
    digitalWrite(13, stat_LED);
}