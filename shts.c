/*
   $ gcc -O6 -o shts shts.c -lpigpio -lrt -lpthread
   $
   
   $ sudo killall pigpiod
   $ sudo ./shts N d f
   $
   N flashes of length d[us] will be generated at frequency f[Hz] on GPIO13.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>

#include <pigpio.h>

#define gpioStrobe 13

int wave_id, N=1;

gpioPulse_t *pulse;

int main(int argc, char *argv[])
{
   unsigned int d,f;
   assert(argc == 1+3);
   assert(0 < (N = atoi(argv[1])));
   assert(0 < (d = atoi(argv[2])));
   assert(0 < (f = atoi(argv[3])));
   f = 1000000/f - d;

   assert(gpioCfgClock(1, 1, 0) >= 0);
       
   assert(gpioInitialise()>=0);

   gpioSetMode(gpioStrobe, PI_OUTPUT);

   gpioWaveAddNew();

   assert(pulse = malloc(sizeof(gpioPulse_t) * (2*N+1)));
   pulse[0].gpioOn  = 0;
   pulse[0].gpioOff = 1<<gpioStrobe;
   pulse[0].usDelay = 2;

   for(int i=1; i<=N; ++i)
   {
      pulse[2*i-1].gpioOn  = 1<<gpioStrobe;
      pulse[2*i-1].gpioOff = 0;
      pulse[2*i-1].usDelay = d;

      pulse[2*i-0].gpioOn  = 0;
      pulse[2*i-0].gpioOff = 1<<gpioStrobe;
      pulse[2*i-0].usDelay = f;
   }

   gpioWaveAddGeneric(2*N+1, pulse);

   wave_id = gpioWaveCreate();

   assert((wave_id >= 0) || !"wave create failed\n");

   gpioWaveTxSend(wave_id, PI_WAVE_MODE_ONE_SHOT);

   usleep(N*(d+f)+1000000);

   gpioTerminate();

   free(pulse);

   return 0;
}
