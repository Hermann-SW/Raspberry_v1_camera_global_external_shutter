## Raspberry v1 camera global external shutter

Associated [Raspberry forum thread](https://www.raspberrypi.org/forums/viewtopic.php?f=43&t=241418).

This is the parent project of [ESP32-CAM ov2640 sensor global (external) shutter](../../tree/master/FCameraWebServer).

* [Introduction](#introduction)
  * [So why do you may want global shutter videos?](#so-why-do-you-may-want-global-shutter-videos)
  * [Comparison of commercially available and diy highspeed flashes](#comparison-of-commercially-available-and-diy-highspeed-flashes)
* [Setup for global external shutter](#setup-for-global-external-shutter)
  * [basic diy highspeed flash capturing](#basic-diy-highspeed-flash-capturing)
  * [two LEDs](#two-leds)
  * [black background](#black-background)
  * [black propeller on black background](#black-propeller-on-black-background)
* [Tools](#tools)
* [Requirements](#requirements)
  * [capturing](#capturing)
  * [post processing](#post-processing)
* [Capturing](#capturing)
* [Single exposure](#single-exposure)
* [Multiple exposure](#multiple-exposure)
  * [shots tool](#shots-tool)
  * [PWM exposure](#pwm-exposure)
  * [Sound trigger](#sound-trigger)
  * [kFPS videos from kEPS multiple exposure frames](#kFPS-videos-from-kEPS-multiple-exposure-frames)
    * [simple technique](#simple-technique)
    * [full and empty frame](#full-and-empty-frame)
    * [camera software panning](#camera-software-panning)
    * [empty frame via heal selection](#empty-frame-via-heal-selection)
    * [circle tool](#circle-tool)
* [Hardware camera sync pulses](#hardware-camera-sync-pulses)
* [Daylight](#daylight)
* [Update wrt rolling shutter camera capturing airgun bullet inflight](#update-wrt-rolling-shutter-camera-capturing-airgun-bullet-inflight)

## Introduction

Raspberry v1 camera (or clone, v1 camera was sold last 2016 by Raspberry Pi Foundation) does not provide a global shutter mode. But it does provide a "global reset" feature/[FREX mode](https://cdn.sparkfun.com/datasheets/Dev/RaspberryPi/ov5647_full.pdf#page=43) (whole frame pixels start integration at the same time, rather than integrating row by row). 

This repo describes how to build an external shutter for v1 camera and provides tools allowing for taking Raspberry v1 camera global external shutter videos.

#### So why do you may want global shutter videos?

Mostly for fast moving scenes. The propeller of mini drone rotates with 26000rpm and has a diameter of 34mm. The radial speed at blade tips is quite high, 0.034m×pi×(26000/60)=46.3m/s(!) or 166.6km/h.


This is a frame you get with v1 camera normal [rolling shutter](https://en.wikipedia.org/wiki/Rolling_shutter) mode, total distortion:  
![rolling shutter demo of propeller rotating with 26000rpm](res/rs.26000rpm.jpg)

This is animation of video taken with global external shutter technique (scene lit by 5000lm led with 36µs strobe pulse duration; 1 second from 25fps video, converted into an animated .gif playing at 5fps, allowing to really see each single global shutter frame, as well as to see that the other propellers+motors are heavily shaken by the front propeller wind):   
![global shutter demo of propeller rotating with 26000rpm](res/26000rpm.anim.gif)

How do you get that? By powering off light quickly after the end of the strobe pulse, and a really dark scene. Only that way further accumulation of light can be avoided for the lower lines of the frame that are sent to Pi from camera later than the very first lines.

These methods for total darkness work:
- close room door and window shutter completely
- cover complete setup (2nd "shots tool" section example) with moving box
- cover only camera, bright light and eg. propeller with moving box 

It turned out that complete darkness is not necessarily needed (although better frames can be captured that way), but only darkness behind fast moving parts. See [Daylight](#daylight) section for details. Just as a teaser, this is 5 exposures frame of fast rotating mini drone propeller captured at daylight:
![res/daylight.4.png](res/daylight.4.png)

#### Comparison of commercially available and diy highspeed flashes

<a name="diycomparison"></a>There are commercially available highspeed flashes like the [Vela One](http://www.vela.io/vela-one-high-speed-flash). Compared to the 5000lm diy highspeed flash described in next section (that has proven to be able to capture with 4µs flash duration), the Vela One has advantages and disadvantages:
- (+) allows for flash durations down to 0.5µs (diy will not provide enough light for that duration)
- (+) provides 1 million lumens compared to 5000lm
- (-) costly (940£) compared to 20$ for diy
- (-) low maximal continuous strobe frequency (50Hz) compared to 20KHz of diy shown already (90KHz possible)

The first point can be mitigated a bit for diy highspeed flash. What really counts is lux, not lumens. For given lumen, lux is inversely quadratric proportional to distance (reducing distance by factor x increases lux by factor x²). The airsoft pellet trajectories just above [5000lm led (without COB reflector) shown below](#user-content-9000eps) provided an immense increase of lux hitting the flying pellet.

## Setup for global external shutter

#### basic diy highspeed flash capturing

This is the setup:
![Setup for global external shutter](res/IMG_270519_182616.jpg)

You need (aliexpress.com free shipping prices):
* very bright 50W 5000lm led (2$)
* 40x40x20mm aluminum heatsink (2$)
* 50W led driver (7$)
* plastic COB reflector (3$)
* IRF520 mosfets (2×1$)
* v1 camera (clone 6$)
* spare drone motor+propeller (4$)

The 0-24V IRF520 mosfets are used in series to control 38V/1.5A from 50W led driver to 5000lm led. Pi GPIO13 is connected with both mosfet SIG pins. Power the propeller from an independent power source, I use a constant voltage power supply because that allows to easily change propeller voltage and by that propeller rpm.

In above photo reflector sits on 5000lm led sits on top of aluminum heatsink. Here is another option for light direction vertically down, aluminum heatsink on top of 5000lm led on top of reflector on top of plexiglas above scene:  
![5000lm led on reflector](res/IMG_290319_182453.quarter.part.jpg)

The smaller the distance from led to object, the more lux from same 5000lm led hit the object (lux is inversely quadratric proportional to distance). In case you can place the object you want to light directly above the led, it is better to not use the reflector at all. The Raspberry v1 camera captures from below led level slightly upwards. This increases brightness of captured frames over using the reflector:  
![setup w/o reflector](res/setup.wo.reflector.png)

See [airshot pistol shot just above 5000lm led without reflector](#user-content-bottom_led) for another example.

#### two LEDs

The captures done for airsoft pistol showed captured pellets with dark top because of led light from bottom only. Adding a 2nd 50W led driver and 2nd 5000 lm led (both connected in parallel) lighting from top resolved this issue, see for [airgun shot](#user-content-bottom_plus_top_led) captured with that setup:  
![setup w/ two leds](res/IMG_060619_182038.jpg)

<a name="setup2leds"></a>This is complete setup with airgun clamped to desk. Some cables are now passed below living room desk in order to not show up in camera view. Lower right cardboard box filled with many thick newspapers acts as pellet catcher. See [9000eps](#user-content-9000eps) airgun pellet capture done with this setup:  
![setup w/ clamped airgun](res/IMG_160619_103844.jpg)

#### black background

<a name="blackBackground"></a>Most of the captures described on this repo were done without a black background. The dark background was achieved with long range of free space behind scene. That works fine because light intensity drops quadratic with distance. For [Sound trigger](#sound-trigger) work I wanted to have setup small and on my desk in reach. I created a black cardboard that I used as dark background, as can be seen on the left. This is not necessary in general if you have long free space after the scene. But if using black cardboard as background with 5000lm led flash, then it needs to be really black. I used "the blackest black" [Black 3.0](https://culturehustle.com/products/black-3-0-the-worlds-blackest-black-acrylic-paint-150ml) from kickstarter campain for that, it absorbs 98% of incoming light. In this setup I did make the 5000lm led with heatsink stand vertically, unlike lighting from bottom or top before. This allowed to use only a single of my two 5000lm leds (this type of lighting is more like the flashes of cameras, from direction of lens):  
![setup w/ black background](res/IMG_020919_214148.jpg)

<a name="daylightSetup"></a>I used a fast rotating mini drone propeller for [experiment in Daylight section](#user-content-daylightexperiment). I did cut a circular disk out of cardboard, did cut a small hole into the center, and then painted one side with black, two times. I used Black 3.0 which absorbs 98% of light, but any other dark black will probably do as well. Then I removed blade from mini drone propeller, did put minimal amount of superglue on the motor around motor shaft (avoiding superglue to reach motor shaft), and did put circular disk over motor shaft. Finally I did put the blade onto motor shaft again. On the left you can see the circular black disk superglued onto the motor, and on the right you can see v1 camera as well as 5000lm led nearby:  
![res/IMG_090919_164318.jpg](res/IMG_090919_164318.jpg)

#### black propeller on black background

<a name="blackBesidesBladeTip"></a>This setup is based on the previous setup. In addition to black cardboard disk, here the blade is painted black as well (besides just one blade tip). That way only the small area at blade tip seems to move, as you can see in left image. In right image you can see the structure (I used Black 3.0 again, absorbing 98% of light). This setup allows for [20000eps frame](#user-content-20000eps):  
![res/propeller_black30.png](res/propeller_black30.png)

<a name="blackBesidesWhite"></a>I just painted another (this time white) propeller black, and made the small area at blade tip narrow in order to be able to place much more markers on frame without overlap than with previous propeller. This setup allows for another [20000eps frame](#user-content-20000epswhite) as well:  
![res/propeller_black30.2nd.png](res/propeller_black30.2nd.png)

## Tools

* [raspivid_ges](tools/raspivid_ges) (if starting with default parameters, captures 2MP tst.h264 video at 1fps global external shutter mode)
* [raspividyuv_ges](tools/raspividyuv_ges) (global external shutter for raspividyuv)
*
* [shot](tools/shot) (single exposure)
*
* [shots](tools/shots) (multiple exposure)
* [5shots](tools/5shots) (sample for different strobe pulse length multiple exposure)  
* [pwm_ges](tools/pwm_ges) (pwm exposure)
* [doit90](tools/doit90) (script for [capturing pellets](#user-content-9000eps))
* [audio_shots.c](tools/audio_shots.c) (used in [Sound trigger](#sound-trigger) section)
*
* [gpio_alert.c](tools/gpio_alert.c) (camera synced multiple exposure sample)
*
* [toFrames](tools/toFrames) (converts .h264 video (tst.h264 by default) to multiple frames (frame0000.jpg, frame0001.jpg, ...))

## Requirements

#### capturing

All capturing commands (raspivid_ges/raspividyuv_ges/shot/shots/5shots/pwm_ges/audio_shots.c/gpio_alert.c) require pigpio library, which can be found here: [http://abyz.me.uk/rpi/pigpio/download.html](http://abyz.me.uk/rpi/pigpio/download.html).

raspivid_ges and raspividyuv_ges require I2C and Camera features being enabled via raspi-config.

All capturing commands besides pwm_ges can be run on any GPIO pin. pwm_ges requires Hardware PWM, which is available on GPIO(12|18) and GPIO(13|19) only (pigpio [software PWM frequencies](http://abyz.me.uk/rpi/pigpio/pigs.html#PFS) are too restricted). 

#### post processing

[Post processing tools](https://stamm-wilbrandt.de/GraphvizFiddle/?1568759435137#digraph%20D%20%7B%0A%20%20rankdir%3DLR%0A%20%20size%3D%228%2C6%22%0A%20%20node%20%5Bshape%3D%22box%22%5D%0A%20%20%7B%20node%20%5Bshape%3D%22ellipse%22%5D%20rank%3D%22same%22%20gcc%20netpbm%20gstreamer%20ffmpeg%20%7D%0A%20%20%22res%2Fmak.210.6.sh%5Cnres%2Fmak.640.5.sh%5Cnres%2F6mm.frame3946.jpg.sh%5Cnres%2Fpointed.pellet.frame0360_undistorted.jpg.sh%22%20-%3E%20%7B%20netpbm%20%22res%2Fpngs2anim%22%20%7D%0A%20%20%22res%2Fmak.210.6.sh%5Cnres%2Fmak.640.5.sh%5Cnres%2F6mm.frame3946.jpg.sh%5Cnres%2Fpointed.pellet.frame0360_undistorted.jpg.sh%22%20-%3E%20%22res%2F20000eps.34.9.41.a.sh%5Cnres%2F20000eps.43.7.43.a.sh%22%20%5Bstyle%3D%22invisible%22%20dir%3D%22none%22%5D%0A%20%20%22res%2F20000eps.34.9.41.a.sh%5Cnres%2F20000eps.43.7.43.a.sh%22%20-%3E%20%7B%20%22res%2Fcircle.c%22%20%22res%2Fpngs2anim%22%20gcc%20netpbm%20%7D%0A%20%20%22res%2Fpngs2anim%22%20-%3E%20%7B%20gstreamer%20ffmpeg%20%7D%20%0A%20%20%22tools%2FtoFrames%22%20-%3E%20ffmpeg%0A%7D) (in boxes) require use of netpbm, gcc, ffmpeg and gstreamer as displayed in this SVG:
![res/req.svg](res/req.svg)

## Capturing

Just calling "raspivid_ges" starts raspivid with default parameters (mode 1 capture at 1fps, 960x540 preview window, flash AWB, output to tst.h264, in background, endless runtime), triggers 2s continuous strobe in parallel to starting raspivid for getting correct settings by AWB, injects I2C commands to bring v1 camera into global external shutter mode and waits for raspivid to end. With default parameter endless runtime you can simply end raspivid_ges by pressing CTRL-C. In case you provide different set of parameters and do some "-t ..." setting, raspivid_ges ends after raspivid completed.

If you want one terminal only (text mode/X11 or ssh session), you can start raspivid_ges in background as well, otherwise you can execute the tools shot/shots/5shots/pwm_ges from a second terminal. You can repeat executing those tools while raspivid_ges is running. In case HDMI monitor is connected, you can directly see the effects on calling such a tool (with a <1s delay) on HDMI monitor preview. One property of global external shutter technique is, that you can look at the rotating propeller directly without HDMI monitor, and see the same global shutter effects directly with just your eyes.

So a session for capturing a single "shot" tool frame example is this:

	$ ssh pi@yourpi
	...
	$ raspivid_ges &
	$ PID=$!
	$ shot
	$ kill -9 $PID
	$ toFrames 
	$ logout
	$ rm -f frame????.jpg; scp pi@yourpi:frame????.jpg .; eog frame????.jpg

You will step through the extracted 2MP frames from captured tst.h264 with eog tool to find the one frame with the captured flash. Alternatively you can sort the frames by size with "ls -lS frame????.jpg | head" and find the captured flash among the biggest frames.

## Single exposure

Single exposure global shutter capturing is when at most one strobe flash happens per frame. Tool [shot](tools/shot) allows you to send a single flash pulse (by default 9µs pulse duration to GPIO13, you can pass different arguments):

	$ shot 9 13
	$

![single exposure frame](res/single-exposure.1.png)

## Multiple exposure

In this scenario more than one strobe flash happens per frame captured. Since by that exposures can be far more frequent than any high framerate video capturing can do (maximally 750fps/1007fps for v1/v2 camera, due to needed slow frame transfer to Pi), this will be called "x eps frame" (exposures per second).  


#### shots tool

Tool [shots](tools/shots) allows to send multiple strobe pulses (by default five 9µs duration pulses, 241µs apart on GPIO13):

	$ shots
	$

This is a "4000 eps frame" (1000000/(9+241)):
![multiple exposure frame3](res/multiple-exposure.3.jpg)

Same scene with different lighting, in case you have no room where you can close all doors and all window shutters. Just put a moving box above the complete setup:
![multiple exposure frame8](res/multiple-exposure.8.part.jpg)

Different parameters example:

	$ shots 9 9 116
	$

This is a "8000 eps frame" (1000000/(9+116)):
![multiple exposure frame6](res/multiple-exposure.6.jpg)


Tool [5shots](tools/5shots) does 5 exposures with different strobe pulse widths (1/3/5/7/9µs):

	$ 5shots
	$

![multiple exposure frameA](res/multiple-exposure.A.jpg)

Same scene with slightly different lighting (you can see 5 blades with reflective tape at bottom):
![multiple exposure frameB](res/multiple-exposure.B.jpg)

"shots 2 9 900000" captures two 9µs duration strobe pulses, 0.9s apart. With raspivid_ges tool's "-fps 1" default setting most times the first flash happens on one tst.h264 frame captured, and the 2nd flash happens on the next frame. But after 15 attempts I was successful and captured both flashes on same frame, proving that it is possible. See section [Hardware camera sync pulses](#hardware-camera-sync-pulses) on how to get both flashes captured on a single frame guaranteed: 
![multiple exposure frameC](res/multiple-exposure.C.jpg)

<a name="20000eps"></a>"shots 34 9 41" captures 34 (9µs long) strobe pulses, 41µs apart. You can find description of the setup [here](#user-content-blackbesidesbladetip). This is a 1000000/(9+41)=20000eps frame. Rotational speed is 1000000/(33.5*50)=597rps or 35820rpm (33.5 because first and last exposure in left bottom of circular disk are a bit too close together, so 34 is too big). With 34mm propeller diameter, speed of the visible dot is 0.034×π×597=63.8m/s or 230km/h:
![res/20000eps.34.9.41.a.png](res/20000eps.34.9.41.a.png)

<a name="20000epsWhite"></a>"shots 43 7 43" captures 43 strobe pulses. I reduced strobe duration to 7µs in order to reduce overall brightness of scene. You can find description of the setup [here](#user-content-blackbesideswhite). This is a 1000000/(7+43)=20000eps frame as well. Rotational speed is 1000000/(43*50)=465rps or 27907rpm. Reason for slower speed was that motor was powered with 3.3V this time, but with 4.3V previously. With 34mm propeller diameter, speed of the visible white marker is 0.034×π×465=49.7m/s or 179km/h:
![res/20000eps.43.7.43.a.png](res/20000eps.43.7.43.a.png)

How 20000fps videos were created from both 20000eps frames is described [here](#empty-frame-via-heal-selection).

#### PWM exposure

Above captures were all radial, this one is linear. The frame captured 6mm diameter airsoft pistol pellet in flight. A fixed length pigpio waveform (as in shots) would need synchronization between triggering shot and triggering waveform (accoustic, laser light barrier or 665/1007fps high framerate video detection).  The simpler approach taken here is to use 3kHz PWM signal on GPIO13 with duty cycle 2.5% (8.33µs). Each 1fps frame gets 3000 flashes. This cannot be done inside moving box because all you would get is a white frame. Tool pwm_ges called without arguments uses exactly those settings as defaults. The command generates 6000 strobe pulses in order to not confuse raspivid AWB:

	$ pwm_ges
	$

This is a "3000 eps frame":
![multiple exposure frame7](res/multiple-exposure.7.jpg)

The frame is not perfect, just the first capture of flying pellet, not sharp because lens was not adjusted well, but it is proof that capturing (rifle) pellets in flight is possible with v1 camera!

The frame allowed to determine pellet speed while flying through camera view! The pellet diameter is 6mm, and I used gimp to measure diameter of pellet as 357 pixel. The distance from left side of 2nd to left side of 3rd pellet in frame was 563 pixels. Pellet speed therefore is (563px / 357px) × 6mm × 3000Hz = 28.38m/s.

Just for completeness, this is the 0.5 Joule 13$ airsoft pistol used, and a 6mm diameter 0.12g pellet:  
![airsoft pistol with pellet](res/airsoft.pistol.jpg)

<a name="bottom_led"></a>With lens sharp, background dark (doing raspivid_ges with framerate 30fps instead of 1fps results in only 100 strobe pulses lighting background for 3kHz PWM),

	$ raspivid_ges -md 1 -p 10,10,960,540 -fps 30 -awb flash -o tst.h264 -pts tst.pts -t 0

and without reflector (for shooting just above the 5000lm led at bottom, in order to increase lumens) muzzle speed is roughly

	(236px / 117px) × 6mm × 3000Hz = 36.3m/s

![airsoft pistol with flying_pellet](res/6mm.frame3946.jpg)

<a name="bottom_plus_top_led"></a>This is first shot of airgun from friend captured with raspiraw_ges:  
![airgun pellet double capture](res/airgun.1a.jpg)

Taken with pwm_ges tool default parameters (8.33µs strobe pulses with 3kHz PWM) and raspivid_ges at framerate 30fps as before. 5mm pellet length is 121px, and distance between heads of both pellets captured is 881px. So muzzle speed is roughly

	(881px / 121px) × 5mm × 3000Hz = 109.2m/s (393km/h)

The recoil of 1-handed shot was surprisingly small (animated .gif created from frames scaled down 3×, 30fps captured frames played at 1fps):  
![airgun pellet frames](res/airgun.1st.anim.gif)


<a name="9000eps"></a>Increasing PWM frequency from 3kHz to 9kHz will get a brighter background with unchanged settings. Since 30fps is maximal framerate for 1920x1080 frames, this frame got captured at 90fps at the price of resolution (now 640x480). Pointed pellet was shot through paper clamped at airgun muzzle, reduced speed of pellet is 96.9m/s, with 96.9m/s / 9000Hz = 1.077cm between exposures:  
![airgun pellet frames](res/pointed.pellet.frame0360.jpg)


Small script [doit90](tools/doit90) was useful in automating what needs to be done for starting capture, get 2s AWB (in pwm_ges), and then start 2s PWM exposure until finally gracefully stop everything. In dark room starting the script allowed to move hand to (clamped on desk airgun) trigger during first 2s bright AWB phase, and then trigger shot during 2s PWM exposure phase.


<a name="9000epsundistorted"></a>The previous frame impressively shows that lens distortion plays a role. I used modified [OpenCV callibrate.py](https://github.com/opencv/opencv/blob/master/samples/python/calibrate.py) with 10 chessboard samples taken with the camera. The undistorted frame shows all pellet exposures on straight line:  
![airgun pellet frames_undistorted](res/pointed.pellet.frame0360_undistorted.jpg)

On the left you can see 8mm long pointed pellet used from a smartphone photo. On the right is in-flight pellet copied out from a frame captured with color problems, but with 1:1 pixel size. It was captured with same FoV as the frame before (but 2MP frame). With camera closer to pellet trajectory and adjusted camera lens much more details could be captured:  
![airgun pellet photo](res/pointed.pellet.photo.jpg) 
![airgun pellet 1to1 capture](res/pointed.pellet.frame0104.part.jpg)

<a name="3pellets"></a>Sometimes it is not needed to increase PWM flash frequency, but to reduce it in order to get non-overlapping exposures. The frame shows 3 pellets shot together by airsoft pistol. Only 300Hz frequency with 9µs long flashes was used (0.27%/300Hz=9µs, command executed was "$ ./pwm_ges 300 2700 3"). The left 3 pellets belong to one exposure, and the right three pellets to the next exposure. A red pellet is slightly heavier than the yellow pellet. Both red pellets keep the common trajectory in this frame. Only yellow pellet falls off the trajectory. Yellow pellet speed 16.4m/s or 59km/h is significantly slower than 36m/s, but here three pellets had to be accelerated and not only one:
![three pellets inflight](res/good.0485.png) 

Todos:
Next step is to use ~air gun for higher muzzle speed, and finally~ a real rifle. A 375m/s pellet does move 0.375mm/µs. If a frame every 3cm is wanted, exposures have to be taken every 30/0.375=80µs. The result will be a 12500 eps(!) frame (1000000/80).  
After that, maybe capturing [.50 bmg](https://en.wikipedia.org/wiki/.50_BMG) with 900m/s(!) might be a challenge. A former colleague of me did shoot .50 bmg ...

#### Sound trigger

There is one disadvantage of PWM exposures:  
A frame gets flash hits very often although the number of captured pellet exposures in a frame is much lower (eg. 100 flash hits for 9000eps pellet capture with 90fps video above, with only 10 pellet exposures in frame). Therefore background for PWM exposure is typically much brighter than needed.

This section describes sound triggered multiple exposure capturing. I used cheap 5V microphone sensor with digital and analog output as sound trigger. I connected GND/VCC/D0/A0 of microphone sensor to GND/3V3/GPIO17/- on the Pi. Although product description does not mention that this sensor works with 3.3V, it does:  
<img width=648 src="res/IMG_010919_223213.jpg"/>

Tool [audio_shots.c](tools/audio_shots.c) can be used for sound triggered multiple exposure. This command waits to be triggered from digital microphone sensor output, then waits for 2010µs offset, and then does 5 (9µs duration) flashes at frequency 6KHz:

    $ sudo killall pigpiod
    $ sudo ./audio_shots 5 9 6000 2010

One frame captured by a 36m/s airsoft pistol shot after the command started is this. Main difference to 6KHz PWM exposure is that pellet exposures on left and right side of frame are missing. Main advantage is that background is darker than with PWM exposure capturing:  
![res/audio_shots.c.5_9_6000_2000.png](res/audio_shots.c.5_9_6000_2000.png)

With 1st argument of audio_shots being "1", single shot capturing is possible. Frames like this can be captured (from [
Ultra high-speed imaging, capturing matrix style bullet time.](https://www.raspberrypi.org/forums/viewtopic.php?t=240442)):  
![res/giphy.gif.020.gif](res/giphy.gif.020.gif)

One investigation done with audio_shots tool already was whether pellet flying with 36m/s speed spins during flight (it spins fast!). I added small blue dot with permanent marker to north and south pole of some pellets. One pole is visible at least, that allowed to "see" whether there is spin or not. This is a capture of a marked pellet, and in fact it rotates. From one exposure to next at 6KHz time increased by 166µs. Looking at the 9 full in view pellet exposures, time passed from left to right is 8*166µs. Lets say the dot does roughly 1/8 of a full rotation. Then a full rotation of the pellet takes 8\*8/6000Hz=0.01066s, rotation speed therefore is 93.75rps or 5625rpm!
![res/pellet.rotation.png](res/pellet.rotation.png)

I enforced two different pellet speeds by making pellet collide with slightly slanted lath. You can see the distances between successive pellets being longer on left side before hitting the lath, than on the right side after. This multiple exposure capture was one captured by several shots with this command (pellet exposure on left side missing because offset 4010µs was slightly too big for this frame):

    $ sudo killall pigpiod; while true; do sudo ./audio_shots 20 9 4000 4010; done

![res/audio_shots.20.9.4000.4010.png](res/audio_shots.20.9.4000.4010.png)

<a name="sound_spin_speed"></a>Now combining spin and two speeds investigation, I did only put one blue dot onto three pellets. I filled the magazine with 2 normal pellets, then the three pellets with a single blue dot, and finally a normal pellet. After starting raspivid_ges in one console, I started this command in another console:

    $ sudo killall pigpiod; while true; do sudo ./audio_shots 20 18 2500 2510; done

I reduced frequency to 2500Hz and doubled exposure to 18µs (OK for "slowly moving" 36m/s pellet). In shooting position, I removed magzine first and did two empty shots, in order to retrieve two candidates for empty.pnm. Then I inserted magazine, aimed at the cross on lath, fired and immediately looked onto the HDMI monitor 1.5m distant. Because raspivid_ges recording is done with 1fps, I was able to verify that the first shot was good. Then I did three more shots the same way with the pellets with 1 single blue dot. Before shooting I had moved the camera view up a little. The bright area above black cardboard does not hurt, and the lath part with cross where the pellet hits was moved out of camera view. This resulted in frame where all pellet exposures happened against black background. On side left of the cross the blue dot shows "slow" rotation as seen before. Interesting is the part after hitting the lath, a completely different rotation of the blue dot. For details see [corresponding fast camera panning animation](#user-content-camera_panning_2) in next section: 

![res/audio_shots.20_18_2500_2510.png](res/audio_shots.20_18_2500_2510.png)

#### kFPS videos from kEPS multiple exposure frames

Now that we can create thousands of eps multiple exposure frames (kEPS), creating kFPS framerate videos from those frames seemed interesting. General purpose tools for that seem to be difficult to create at least (a frame with same view without the moving object would be helpful).

Fastest framerates for raspivid (640x480) videos are 90fps for v1 camera and 200fps for v2 camera. Fastest framerates for raspiraw videos are 665fps for v1 camera (640x64) and 1007fps for v2 camera (640x75). Creating kFPS framerate videos from kEPS multiple exposure frames is the only way for Raspberry v1 camera (not possible with v2 camera) to create this kind of super high framerate videos. And these vidoes can be of quite big frame size like the 2MP airsoft pistol multiple exposure frame.

###### simple technique

[6mm.frame3946.jpg.sh](res/6mm.frame3946.jpg.sh) is a simple tool based on netpbm image tools and ffmpeg. It takes [6mm.frame3946.jpg](res/6mm.frame3946.jpg) image as input. The coordinates of the moving parts (left/top/width/height) used in the script were determined manually with gimp. The 3000fps animation was created with this command (scaled down from 1920 to 640 horizontally, animation framerate 2fps, 1500 times slower than real):

	./6mm.frame3946.jpg.sh 640 2

![res/6mm.frame3946.jpg.640.2.anim.gif](res/6mm.frame3946.jpg.640.2.anim.gif)

Second tool [pointed.pellet.frame0360_undistorted.jpg.sh](res/pointed.pellet.frame0360_undistorted.jpg.sh) uses same technique. It takes (594x438) [pointed.pellet.frame0360_undistorted.jpg](res/pointed.pellet.frame0360_undistorted.jpg) image as input. The coordinates of the moving parts were determined as before with gimp. The 9000fps animation was created with this command (no scaling horizontally, animation framerate 3fps, 3000 times slower than real):

	./pointed.pellet.frame0360_undistorted.jpg.sh 594 3

The video does not look as nice as the previous one. Reason is that the tool simply filled the area of the moving object with black, which is no problem for the first video with its nearly black background. It will be beneficial for new kEPS multiple exposure frames to move out the 5000lm leds from camera FOV in order to get a nearly black background again: 

![res/pointed.pellet.frame0360_undistorted.jpg.594.3.anim.gif](res/pointed.pellet.frame0360_undistorted.jpg.594.3.anim.gif)

The sript is now modified so that it allows for optional 3rd and 4th argument. The numbers are the top/bottom lines to keep from the original image, the middle part will be filled black. This allows a slightly better animation although the original image background is too bright. Animation was created by this command:

	./pointed.pellet.frame0360_undistorted.jpg.sh 594 3 70 20

![res/pointed.pellet.frame0360_undistorted.jpg.594.3.70.20.anim.gif](res/pointed.pellet.frame0360_undistorted.jpg.594.3.70.20.anim.gif)

###### full and empty frame

<a name="empty_full"></a>Tool [mak.640.5.sh](res/mak.640.5.sh) does not just fill the pellet exposures with black. Instead it takes two 2MP frames, one frame with pellet exposures [full.pnm](res/full.pnm) and another frame taken with same multiple exposures but without pellets captured [empty.pnm](res/empty.pnm):  
![res/pellets.empty-full.png](res/pellets.empty-full.png)  
For the different frames of the animation a single full height rectangle is taken from full.pnm and overlayed onto empty.pnm, and these frames are converted to video and animated .gif as before. The 1920x1080 frames get scaled down to width 640. 5000eps frame full.pnm gets 5000fps video that way; the animation plays at 5fps, 1000 times slower than real:  

![res/frame.640.5.anim.gif](res/frame.640.5.anim.gif)

###### camera software panning

<a name="camera_panning"></a>In [Sound trigger](#sound-trigger) section the pellet capture with blue dots on pellet north and south pole did show that pellet is spinning fast (5625rpm). Since an animation tells more than 1000 words, tool [mak.210.6.sh](res/mak.210.6.sh) creates a 6000fps animation for that 6000eps frame, this time with a very fast camera panning. The animation shows the spinnining with moving blue dot clearly; played at 6fps, 1000× slower than real:

![res/frame.210.6.anim.gif](res/frame.210.6.anim.gif)

<a name="camera_panning_2"></a>This is another very fast camera panning animation. It is done on frame with pellet exposures with 1 blue dot only, for the fully visible pellet exposures after hitting a lath [as described in Sound trigger section](#user-content-sound_spin_speed) show a completely different kind of spin:

![res/frame.180.5.anim.gif](res/frame.180.5.anim.gif)

As can be seen in the animation, this time a rotation of the blue dot is complete in roughly 5 frames. With capturing frequency of 2500Hz that is 500rps or 30000rpm rotation speed. Pellet spin is a normal rotation, around line through center of the circle described by blue dots and pellet center.

###### empty frame via heal selection

For the [20000eps frames](#user-content-20000eps) it is difficult to get an empty frame. Touching the propeller is likely to result in a different FoV captured.

I learned that gimp's "Filters->Enhance->Heal selection" allows to let objects disappear from an image. After installing gimp-resynthesizer package that function (among many others) became available. I just created a selection of some markers and did heal the selection. After done with all markers, I selected some strange artefacts created by healing and healed them away as well. Right frame is healed left frame and acts as empty frame:  
<nobr><img width=384 src="res/20000eps.43.7.43.a.png"> <img width=384 src="res/20000eps.43.7.43.a.empty.png"></nobr>

###### circle tool

I did not want to determine the coordinates of the white narrow markers manually using gimp. So I wrote tool [circle.c](res/circle.c) that has two modes. In first mode it overlays fixed diameter white circles over the full frame allowing to see what the programs parameters result in. Looking at the generated overlay image with an image viewer that automaticlly updates on file change (I used "eog"), the display gets updates for each command run with changed parameters. A single run of "circle.c" could suffice to cover all markers. But the full frame is no perfect circle, it is an ellipse instead due to perspective. This command covers top right quarter of the markers:

    $ ./circle 1340 495 350 93 8.7 11 20000eps.43.7.43.a 45x45 >y.pnm 2>>/dev/null 

Shell script 20000eps.43.7.43.a.sh contains 4 circle commands covering all markers:  
![res/20000eps.circle.anim.gif](res/20000eps.circle.anim.gif)

The shell script uses "circle.c" in second mode, where for the determined coordinates netpbm commands get created. Instead of 45x45.pgm used before, in this mode 45x45.full.pgm gets used, which is a filled circle with diameter 45 pixels. For a given coordinate the full circle gets overlayed onto a fully black 1920x1080 frame, and then this temporary portable grey map is used to cut out one marker from full frame and overlay it on empty frame. After having created the single frames needed this way, gstreamer and ffmpeg are used (in [pngs2anim](res/pngs2anim) tool) as before to create animated .gif from those frames. Executing the shell script generates the first 20000fps video, played at 20fps, 1000× slower than real:

    $ 20000eps.43.7.43.a.sh

![res/20000eps.43.7.43.a.anim.gif](res/20000eps.43.7.43.a.anim.gif)

Having this technique, creating shell script for the other 20000eps frame was easy (played at 20fps, 1000× slower than real):

    $ 20000eps.34.9.41.a.sh

![res/20000eps.34.9.41.a.anim.gif](res/20000eps.34.9.41.a.anim.gif)

## Hardware camera sync pulses

Tool [shots](tools/shots) is not synced with camera frames. shots tool might split its strobe pulses onto more than one frame because of the missing synchronization with camera.

In thread "Hardware camera sync pulses"  
[https://www.raspberrypi.org/forums/viewtopic.php?f=43&t=190314](https://www.raspberrypi.org/forums/viewtopic.php?f=43&t=190314)  
it was stated that as of the 22nd July 2017 firmware, there is support for repurposing the camera LED GPIO to change state on frame start and frame end interrupts.

As described in one of my postings in that thread I was able to make the hardware camera sync pulses appear on GPIO18.

New tool [gpio_alert.c](tools/gpio_alert.c) is camera synced multiple exposure sample. You compile it with 

	$ gcc -O6 -o gpio_alert gpio_alert.c -lpigpio -lrt -lpthread
	$

The tool uses GPIO13 for triggering two 9µs strobe pulses, 925000µs apart, synced with camera. Therefore both strobe pulses will always appear on a single frame captured with "-fps 1". I tested with pulses 950000µs apart, and there strobe pulses are split onto two frames in a strange way:  
[1st strange frame](https://raw.githubusercontent.com/Hermann-SW/Raspberry_v1_camera_global_external_shutter/master/res/two.HWsync.0a.jpg)  
[2nd strange frame](https://raw.githubusercontent.com/Hermann-SW/Raspberry_v1_camera_global_external_shutter/master/res/two.HWsync.0b.jpg)  


raspivid_ges starts pigpiod. For running gpio_alert, the daemon needs to be killed first after having started raspivid_ges:

	$ sudo killall pigpiod
	$ sudo ./gpio_alert 10
	$

The argument that has to be passed is the number of frames with camera synced double exposure.

This is one sample frame capture that way:
![HW camera synced multiple exposure](res/two.HWsync.1.jpg)

This is another sample frame capture that way, which looks different because of small changes in propeller speed:
![HW camera synced multiple exposure](res/two.HWsync.3.jpg)


## Daylight

This is capture of airsoft pistol pellet colliding with slightly slated lath, as described in [Sound trigger](#sound-trigger) section. The difference is, that room window shutter was not closed. So this is a real global shutter capture (not "global external shutter" anymore). The 5000lm led is close to the scene, you can see it in left bottom. The pellet exposures before black cardboard look nearly as good as those taken in dark room. What you can see in addition is, that the pellet just reflected from lath cannot be seen at all, because lath is too bright. What you can see as well is that the wooden side of chest of drawers shines through leftmost pellet exposure. While darkness is not necessary, it is beneficial to exposure quality in frame though:
![res/daylight.2.png](res/daylight.2.png)

<a name="daylightExperiment"></a>For below global shutter frame the setup used is described [here](#user-content-daylightsetup). In order to not get too bright frames, 2MP recording is done with 30fps framerate. The capture was done with this command in one console:

    ./raspivid_ges -md 1 -p 10,10,960,540 -fps 30 -awb flash -o tst.h264 -t 0

And this command in another console, executed a few times for being able to select best frame:

    ./shots 5 9 116

The frame has sharp blade exposures caught in 5 locations, daylight scene around circular disk, colors! From 1st to 5th blade exposure time passed is 4×(9µs+116µs)=500µs, and the covered part of black circular disk is roughly 1/3rd. The rotational speed of blade is therefore 2000/3=666.66rps or 40000rpm! Propeller diameter is 34mm, so rotational speed at blade tip is 0.034×π×40000/60=71.2m/s or 256.3km/h:
![res/daylight.4.png](res/daylight.4.png)


## Update wrt. rolling shutter camera capturing airgun bullet inflight

13 months have passed, and it turned out that global shutter is not needed for capturing airgun bullets inflight. Raspberry HQ (rolling shutter) camera was able to capture multiple exposures, even at daylight, and still show the bullet nicely because of single digit microsecond bright flash duration:  
[https://www.raspberrypi.org/forums/viewtopic.php?f=43&t=288886](https://www.raspberrypi.org/forums/viewtopic.php?f=43&t=288886)  
![res/frame.0137.png.jpg](res/frame.0137.png.jpg)
