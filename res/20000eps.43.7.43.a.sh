#!/bin/sh
nam=`basename $0 ".sh"`
cir="45x45"
N=43
rm -f m
gcc circle.c -o circle -lm
./circle 1340 490 350 190 8.25 11 $nam $cir >/dev/null 2>>m
./circle 1340 500 350 280 8.15 11 $nam $cir >/dev/null 2>>m
./circle 1340 495 350  10 8.35 10 $nam $cir >/dev/null 2>>m
./circle 1340 495 350  93 8.7  11 $nam $cir >/dev/null 2>>m
export i=$N; sh m; ./pngs2anim $nam
rm x.ogg m temp.pgm x.??.png $nam.pnm $nam.empty.pnm
