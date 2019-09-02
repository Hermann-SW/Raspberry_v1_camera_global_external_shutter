/*
   $ gcc -O6 -o audio_shots audio_shots.c -lpigpio -lrt -lpthread
   $
   
   After start of raspivid_ges:
   $ sudo killall pigpiod
   $ sudo ./audio_alert N d f o
   $
   audio_alert waits for digital audio signal.
   After o[us], N flashes of length d[us] will be generated at frequency f[Hz].
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>

#include <pigpio.h>

#define gpioStrobe 13
#define gpioDaudio 17

int wave_id, N=1, done=0;

gpioPulse_t *pulse;

void alert(int gpio, int level, uint32_t tick)
{
   if (level!=0)  return;

   gpioWaveTxSend(wave_id, PI_WAVE_MODE_ONE_SHOT);

   done=1;
}

int main(int argc, char *argv[])
{
   unsigned int d,f,o;
   assert(argc == 1+4);
   assert(0 < (N = atoi(argv[1])));
   assert(0 < (d = atoi(argv[2])));
   assert(0 < (f = atoi(argv[3])));
   f = 1000000/f - d;
   assert(0 < (o = atoi(argv[4])));
       
   assert(gpioInitialise()>=0);

   gpioSetMode(gpioStrobe, PI_OUTPUT);

   gpioWaveAddNew();

   assert(pulse = malloc(sizeof(gpioPulse_t) * (2*N+1)));
   pulse[0].gpioOn  = 0;
   pulse[0].gpioOff = 1<<gpioStrobe;
   pulse[0].usDelay = o;

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

   gpioSetAlertFunc(gpioDaudio, alert);


   while (! done)  usleep(100000);

   usleep(N*(d+f)+1000000);

   gpioTerminate();

   free(pulse);

   return 0;
}
