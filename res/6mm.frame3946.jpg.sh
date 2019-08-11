#!/bin/sh
width=$1
fps=$2
jpg="6mm.frame3946.jpg"
pnm="frame.pnm"
avi="frame.avi"
gif="$jpg.$width.$fps.anim.gif"

jpegtopnm $jpg > $pnm 2>/dev/null

pnmcut -left 1340 -top 450 -width 170 -height 160 $pnm > cut1.pnm
pnmpad -left 1340 -top 450 -right 410 -bottom 470 cut1.pnm > pad1.pnm

pnmcut -left 1100 -top 450 -width 180 -height 170 $pnm > cut2.pnm
pnmpad -left 1100 -top 450 -right 640 -bottom 460 cut2.pnm > pad2.pnm

pnmcut -left 870 -top 430 -width 170 -height 190 $pnm > cut3.pnm
pnmpad -left 870 -top 430 -right 880 -bottom 460 cut3.pnm > pad3.pnm

pnmcut -left 630 -top 430 -width 180 -height 170 $pnm > cut4.pnm
pnmpad -left 630 -top 430 -right 1110 -bottom 480 cut4.pnm > pad4.pnm

pnmcut -left 400 -top 420 -width 170 -height 170 $pnm > cut5.pnm
pnmpad -left 400 -top 420 -right 1350 -bottom 490 cut5.pnm > pad5.pnm

pnmcut -left 180 -top 410 -width 160 -height 170 $pnm > cut6.pnm
pnmpad -left 180 -top 410 -right 1580 -bottom 500 cut6.pnm > pad6.pnm

pnmcut -left 0 -top 400 -width 130 -height 180 $pnm > cut7.pnm
pnmpad -left 0 -top 400 -right 1790 -bottom 500 cut7.pnm > pad7.pnm

pnmarith -subtract $pnm pad1.pnm | \
pnmarith -subtract - pad2.pnm | \
pnmarith -subtract - pad3.pnm | \
pnmarith -subtract - pad4.pnm | \
pnmarith -subtract - pad5.pnm | \
pnmarith -subtract - pad6.pnm | \
pnmarith -subtract - pad7.pnm > 0.pnm

pnmarith -subtract $pnm pad2.pnm | \
pnmarith -subtract - pad3.pnm | \
pnmarith -subtract - pad4.pnm | \
pnmarith -subtract - pad5.pnm | \
pnmarith -subtract - pad6.pnm | \
pnmarith -subtract - pad7.pnm > 1.pnm

pnmarith -subtract $pnm pad1.pnm | \
pnmarith -subtract - pad3.pnm | \
pnmarith -subtract - pad4.pnm | \
pnmarith -subtract - pad5.pnm | \
pnmarith -subtract - pad6.pnm | \
pnmarith -subtract - pad7.pnm > 2.pnm

pnmarith -subtract $pnm pad1.pnm | \
pnmarith -subtract - pad2.pnm | \
pnmarith -subtract - pad4.pnm | \
pnmarith -subtract - pad5.pnm | \
pnmarith -subtract - pad6.pnm | \
pnmarith -subtract - pad7.pnm > 3.pnm

pnmarith -subtract $pnm pad1.pnm | \
pnmarith -subtract - pad2.pnm | \
pnmarith -subtract - pad3.pnm | \
pnmarith -subtract - pad5.pnm | \
pnmarith -subtract - pad6.pnm | \
pnmarith -subtract - pad7.pnm > 4.pnm

pnmarith -subtract $pnm pad1.pnm | \
pnmarith -subtract - pad2.pnm | \
pnmarith -subtract - pad3.pnm | \
pnmarith -subtract - pad4.pnm | \
pnmarith -subtract - pad6.pnm | \
pnmarith -subtract - pad7.pnm > 5.pnm

pnmarith -subtract $pnm pad1.pnm | \
pnmarith -subtract - pad2.pnm | \
pnmarith -subtract - pad3.pnm | \
pnmarith -subtract - pad4.pnm | \
pnmarith -subtract - pad5.pnm | \
pnmarith -subtract - pad7.pnm > 6.pnm

pnmarith -subtract $pnm pad1.pnm | \
pnmarith -subtract - pad2.pnm | \
pnmarith -subtract - pad3.pnm | \
pnmarith -subtract - pad4.pnm | \
pnmarith -subtract - pad5.pnm | \
pnmarith -subtract - pad6.pnm > 7.pnm

ffmpeg -framerate $fps -i %01d.pnm $avi

# doc:   http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
# needs: ffmpeg

palette="/tmp/palette.png"

filters="fps=$fps,scale=$width:-1:flags=lanczos"

ffmpeg -v warning -i $avi -vf "$filters,palettegen" -y $palette
ffmpeg -v warning -i $avi -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $gif

rm frame* pad* cut* ?.pnm
