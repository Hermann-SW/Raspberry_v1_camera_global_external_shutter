/*
   $ gcc -O6 -o gpio_alert gpio_alert.c -lpigpio -lrt -lpthread
   $
   
   After start of raspivid_ges:
   $ sudo killall pigpiod
   $ sudo ./gpio_alert N
   $
   will sync to frame end and do two 9µs strobe pulses, 925000µs apart.
   The two flashes will show up on a single frame with raspivid_ges "-fps 1".
   There will be N consecutive camera synced double exposure frames.
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>

#include <pigpio.h>

#define gpioStrobe 13
#define gpioHWsync 18

int wave_id, N=1;

gpioPulse_t pulse[5]={
   {0,1<<gpioStrobe,2},      {1<<gpioStrobe,0,9},
   {0,1<<gpioStrobe,925000}, {1<<gpioStrobe,0,9},
   {0,1<<gpioStrobe,0}
};

void alert(int gpio, int level, uint32_t tick)
{
   if (level!=0)  return;

   if (--N == 0)  gpioSetAlertFunc(gpioHWsync, NULL);

   gpioWaveTxSend(wave_id, PI_WAVE_MODE_ONE_SHOT);
}

int main(int argc, char *argv[])
{
   assert(argc > 1);
   assert(0 < (N = atoi(argv[1])));
       
   assert(gpioInitialise()>=0);

   gpioSetMode(gpioStrobe, PI_OUTPUT);

   gpioWaveAddNew();

   gpioWaveAddGeneric(sizeof(pulse)/sizeof(pulse[0]), pulse);

   wave_id = gpioWaveCreate();

   assert((wave_id >= 0) | !"wave create failed\n");

   gpioSetAlertFunc(gpioHWsync, alert);

   sleep(3+N);

   gpioTerminate();
}
