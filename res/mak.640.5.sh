#!/bin/bash
width=$1
fps=$2
avi="frame.avi"
gif="frame.$width.$fps.anim.gif"

empty="empty.pnm"
full="full.pnm"

cp $empty p.00.pnm

# 180 480 774 1060 1346 1630

pnmcat -leftright \
<(pnmcut -left    0 -top 0 -width  180 -height 1080 $full)  \
<(pnmcut -left  180 -top 0 -width 1740 -height 1080 $empty) \
> p.01.pnm

pnmcat -leftright \
<(pnmcut -left    0 -top 0 -width  180 -height 1080 $empty) \
<(pnmcut -left  180 -top 0 -width  300 -height 1080 $full)  \
<(pnmcut -left  480 -top 0 -width 1440 -height 1080 $empty) \
> p.02.pnm

pnmcat -leftright \
<(pnmcut -left    0 -top 0 -width  480 -height 1080 $empty) \
<(pnmcut -left  480 -top 0 -width  294 -height 1080 $full)  \
<(pnmcut -left  774 -top 0 -width 1146 -height 1080 $empty) \
> p.03.pnm

pnmcat -leftright \
<(pnmcut -left    0 -top 0 -width  774 -height 1080 $empty) \
<(pnmcut -left  774 -top 0 -width  286 -height 1080 $full)  \
<(pnmcut -left 1060 -top 0 -width  860 -height 1080 $empty) \
> p.04.pnm

pnmcat -leftright \
<(pnmcut -left    0 -top 0 -width 1060 -height 1080 $empty) \
<(pnmcut -left 1060 -top 0 -width  286 -height 1080 $full)  \
<(pnmcut -left 1346 -top 0 -width  574 -height 1080 $empty) \
> p.05.pnm

pnmcat -leftright \
<(pnmcut -left    0 -top 0 -width 1346 -height 1080 $empty) \
<(pnmcut -left 1346 -top 0 -width  284 -height 1080 $full)  \
<(pnmcut -left 1630 -top 0 -width  290 -height 1080 $empty) \
> p.06.pnm

pnmcat -leftright \
<(pnmcut -left    0 -top 0 -width 1630 -height 1080 $empty) \
<(pnmcut -left 1630 -top 0 -width  290 -height 1080 $full) \
> p.07.pnm


ffmpeg -framerate $fps -i p.%02d.pnm $avi

# doc:   http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
# needs: ffmpeg

palette="/tmp/palette.png"

filters="fps=$fps,scale=$width:-1:flags=lanczos"

ffmpeg -v warning -i $avi -vf "$filters,palettegen" -y $palette
ffmpeg -v warning -i $avi -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $gif

rm frame.avi p.0[0-7].pnm
