#!/bin/sh
nam=`basename $0 ".sh"`
cir="40x40"
N=34
rm -f m
gcc circle.c -o circle -lm
./circle 896 512 364 -22.9 10.9 13 $nam $cir >/dev/null 2>>m
./circle 896 512 364 116.7 10.7 21 $nam $cir >/dev/null 2>>m
export i=$N; sh m; ./pngs2anim $nam
rm x.ogg m temp.pgm x.??.png $nam.pnm $nam.empty.pnm
