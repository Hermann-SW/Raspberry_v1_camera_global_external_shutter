/*
   $ gcc -O6 -o gpio_alert gpio_alert.c -lpigpio -lrt -lpthread
   $
   
   After start of raspivid_ges:
   $ sudo killall pigpiod
   $ sudo ./gpio_alert
   $
   will sync to frame end and do two 9µs strobe pulses, 925000µs apart.
   The two flashes will show up on a single frame with raspivid_ges "-fps 1".
*/
#include <stdio.h>
#include <unistd.h>

#include <pigpio.h>

int wave_id, secs=4, gpio=13, gpioHWsync=18;

void alert(int gpio, int level, uint32_t tick)
{
   if (level!=0)  return;

   gpioSetAlertFunc(gpioHWsync, NULL);
   gpioWaveTxSend(wave_id, PI_WAVE_MODE_ONE_SHOT);
}

int main(int argc, char *argv[])
{
   gpioPulse_t pulse[5]={
     {0,1<<gpio,2},      {1<<gpio,0,9},
     {0,1<<gpio,925000}, {1<<gpio,0,9},
     {0,1<<gpio,0}
   };

   if (gpioInitialise()<0) return 1;

   gpioSetMode(gpio, PI_OUTPUT);

   gpioWaveAddNew();

   gpioWaveAddGeneric(sizeof(pulse)/sizeof(pulse[0]), pulse);

   wave_id = gpioWaveCreate();

   if (wave_id < 0)
   {
      fprintf(stderr, "wave create failed\n");
      return 1;
   }

   gpioSetAlertFunc(gpioHWsync, alert);

   sleep(secs);

   gpioTerminate();
}
