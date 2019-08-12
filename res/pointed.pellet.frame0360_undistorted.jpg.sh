#!/bin/sh
width=$1
fps=$2
jpg="pointed.pellet.frame0360_undistorted.jpg"
pnm="frame.pnm"
avi="frame.avi"
gif="$jpg.$width.$fps.anim.gif"

# file extension is wrong, should have been .png (594x438)
pngtopnm $jpg > $pnm 2>/dev/null

pnmcut -left 0 -top 290 -width 40 -height 40 $pnm > cut01.pnm
pnmpad -left 0 -top 290 -right 554 -bottom 108 cut01.pnm > pad01.pnm

pnmcut -left 40 -top 290 -width 65 -height 40 $pnm > cut02.pnm
pnmpad -left 40 -top 290 -right 489 -bottom 108 cut02.pnm > pad02.pnm

pnmcut -left 105 -top 290 -width 65 -height 40 $pnm > cut03.pnm
pnmpad -left 105 -top 290 -right 424 -bottom 108 cut03.pnm > pad03.pnm

pnmcut -left 170 -top 290 -width 65 -height 40 $pnm > cut04.pnm
pnmpad -left 170 -top 290 -right 359 -bottom 108 cut04.pnm > pad04.pnm

pnmcut -left 235 -top 290 -width 65 -height 40 $pnm > cut05.pnm
pnmpad -left 235 -top 290 -right 294 -bottom 108 cut05.pnm > pad05.pnm

pnmcut -left 300 -top 290 -width 65 -height 40 $pnm > cut06.pnm
pnmpad -left 300 -top 290 -right 229 -bottom 108 cut06.pnm > pad06.pnm

pnmcut -left 365 -top 290 -width 75 -height 40 $pnm > cut07.pnm
pnmpad -left 365 -top 290 -right 154 -bottom 108 cut07.pnm > pad07.pnm

pnmcut -left 440 -top 290 -width 65 -height 40 $pnm > cut08.pnm
pnmpad -left 440 -top 290 -right 89 -bottom 108 cut08.pnm > pad08.pnm

pnmcut -left 505 -top 290 -width 65 -height 40 $pnm > cut09.pnm
pnmpad -left 505 -top 290 -right 24 -bottom 108 cut09.pnm > pad09.pnm

pnmcut -left 570 -top 290 -width 24 -height 40 $pnm > cut10.pnm
pnmpad -left 570 -top 290 -right 0 -bottom 108 cut10.pnm > pad10.pnm

pnmarith -subtract $pnm pad01.pnm | \
pnmarith -subtract - pad02.pnm | \
pnmarith -subtract - pad03.pnm | \
pnmarith -subtract - pad04.pnm | \
pnmarith -subtract - pad05.pnm | \
pnmarith -subtract - pad06.pnm | \
pnmarith -subtract - pad07.pnm | \
pnmarith -subtract - pad08.pnm | \
pnmarith -subtract - pad09.pnm | \
pnmarith -subtract - pad10.pnm > 00.pnm

if [ "$3" != "" ];
then
  h=$((438 - $3 - $4))
  echo $h
  pnmcut -left 0 -top $3 -width 594 -height $h $pnm > 01.pnm
  pnmpad -left 0 -top $3 -right 0 -bottom $4 01.pnm > 02.pnm
  pnmarith -subtract $pnm 02.pnm > 00.pnm
  gif="$jpg.$width.$fps.$3.$4.anim.gif"
fi

pnmarith -add 00.pnm pad01.pnm > 01.pnm
pnmarith -add 00.pnm pad02.pnm > 02.pnm
pnmarith -add 00.pnm pad03.pnm > 03.pnm
pnmarith -add 00.pnm pad04.pnm > 04.pnm
pnmarith -add 00.pnm pad05.pnm > 05.pnm
pnmarith -add 00.pnm pad06.pnm > 06.pnm
pnmarith -add 00.pnm pad07.pnm > 07.pnm
pnmarith -add 00.pnm pad08.pnm > 08.pnm
pnmarith -add 00.pnm pad09.pnm > 09.pnm
pnmarith -add 00.pnm pad10.pnm > 10.pnm


ffmpeg -framerate $fps -i %02d.pnm $avi

# doc:   http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
# needs: ffmpeg

palette="/tmp/palette.png"

filters="fps=$fps,scale=$width:-1:flags=lanczos"

ffmpeg -v warning -i $avi -vf "$filters,palettegen" -y $palette
ffmpeg -v warning -i $avi -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $gif

rm frame* pad* cut* ??.pnm
