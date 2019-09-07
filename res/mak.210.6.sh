#!/bin/bash
width=210
fps=6
avi="frame.avi"
gif="frame.$width.$fps.anim.gif"

img="pr.pnm"
blk="blk.pnm"

pngtopnm pellet.rotation.png > $img

# 112 318 522 722 916 1106 1290 1476 1660 1842

pnmcat -leftright \
<(pnmcut -left  112 -top 552 -width  206 -height 244 $img) \
<(pnmcut -left    0 -top 552 -width    4 -height 244 $blk) \
> p.00.pnm
pnmcat -leftright \
<(pnmcut -left  318 -top 552 -width  204 -height 244 $img) \
<(pnmcut -left    0 -top 552 -width    6 -height 244 $blk) \
> p.01.pnm
pnmcat -leftright \
<(pnmcut -left  522 -top 552 -width  200 -height 244 $img) \
<(pnmcut -left    0 -top 552 -width   10 -height 244 $blk) \
> p.02.pnm
pnmcat -leftright \
<(pnmcut -left  722 -top 552 -width  194 -height 244 $img) \
<(pnmcut -left    0 -top 552 -width   16 -height 244 $blk) \
> p.03.pnm
pnmcat -leftright \
<(pnmcut -left  916 -top 552 -width  190 -height 244 $img) \
<(pnmcut -left    0 -top 552 -width   20 -height 244 $blk) \
> p.04.pnm
pnmcat -leftright \
<(pnmcut -left 1106 -top 552 -width  184 -height 244 $img) \
<(pnmcut -left    0 -top 552 -width   26 -height 244 $blk) \
> p.05.pnm
pnmcat -leftright \
<(pnmcut -left 1290 -top 552 -width  186 -height 244 $img) \
<(pnmcut -left    0 -top 552 -width   24 -height 244 $blk) \
> p.06.pnm
pnmcat -leftright \
<(pnmcut -left 1476 -top 552 -width  184 -height 244 $img) \
<(pnmcut -left    0 -top 552 -width   24 -height 244 $blk) \
> p.07.pnm
pnmcat -leftright \
<(pnmcut -left 1660 -top 552 -width  182 -height 244 $img) \
<(pnmcut -left    0 -top 552 -width   28 -height 244 $blk) \
> p.08.pnm

rm -f $avi 
ffmpeg -framerate $fps -i p.%02d.pnm $avi

# doc:   http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
# needs: ffmpeg

palette="/tmp/palette.png"

filters="fps=$fps,scale=$width:-1:flags=lanczos"

ffmpeg -v warning -i $avi -vf "$filters,palettegen" -y $palette
ffmpeg -v warning -i $avi -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $gif

rm $avi p.??.pnm $img
