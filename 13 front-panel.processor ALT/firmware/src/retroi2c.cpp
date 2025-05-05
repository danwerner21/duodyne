#include <ArduinoOTA.h>
#include <HardwareSerial.h>
#include <SPI.h>
#include <SD.h>
#include <Wire.h>
//#include <Adafruit_GFX.h>
//#include <Adafruit_SSD1306.h>

#include <stdio.h>
#include <cstring>


#include "retrowifi.h"
#include "pins.h"

void onRequest()
{
        char message[64];
        snprintf(message, 64, "HELLO1");
        Wire.slaveWrite((uint8_t *)message, strlen(message));
        Serial.println("onRequest");
        Serial.println();
}

void onReceive(int len)
{
        Serial.printf("onReceive[%d]: ", len);
        while (Wire.available())
        {
                Serial.write(Wire.read());
        }
        Serial.println();
}
void i2cSetup()
{
        char message[64];
        Serial.setDebugOutput(true);
        Wire.setPins(DUODYNEI2C_SDA, DUODYNEI2C_SCL);
        Wire.onReceive(onReceive);
        Wire.onRequest(onRequest);

        Preferences preferences;
        preferences.begin("retroESP32", false);
        uint8_t displayAddress = preferences.getInt("DisplayAddress", 0x55);
        preferences.end();

        Serial.printf("Display I2C Address:0x%x \n\r ", displayAddress);
        Serial.printf("I2C Init\n\r");

        Wire.begin(displayAddress, DUODYNEI2C_SDA, DUODYNEI2C_SCL, 100000UL);
        snprintf(message, 64, "HELLO");
        Wire.slaveWrite((uint8_t *)message, strlen(message));
}

/*
#define I2C_SLAVE_ADDR 0x50  // Replace with your desired slave address

static void i2c_slave_task(void *arg) {
    i2c_config_t conf;
    conf.mode = I2C_MODE_SLAVE;
    conf.sda_io_num = DUODYNEI2C_SDA;    // Replace with the GPIO pin number for SDA
    conf.sda_pullup_en = GPIO_PULLUP_ENABLE;
    conf.scl_io_num = DUODYNEI2C_SCL;    // Replace with the GPIO pin number for SCL
    conf.scl_pullup_en = GPIO_PULLUP_ENABLE;
    conf.slave.addr_10bit_en = 0;
    conf.slave.slave_addr = I2C_SLAVE_ADDR;

    i2c_param_config(I2C_NUM_0, &conf);
    //i2c_driver_install(I2C_NUM_0, conf.mode,  0, 0, 0);
    i2c_driver_install(I2C_NUM_0, conf.mode, 128, 128, 0);
    printf("i2c Driver Installed\n");

    uint8_t data_received;
    while (1) {
        i2c_slave_read_buffer(I2C_NUM_0, &data_received, 1, portMAX_DELAY);
        printf("Received data: 0x%02x\n", data_received);

        // Process the received data or perform any necessary actions

        // Send response data back to the master
        uint8_t response_data = 0xAA;  // Change this to your response data
        i2c_slave_write_buffer(I2C_NUM_0, &response_data, 1, portMAX_DELAY);
    }
}

void i2cSetup() {
    xTaskCreate(i2c_slave_task, "i2c_slave_task", 2048, NULL, 10, NULL);
}

*/