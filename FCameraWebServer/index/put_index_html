#!/bin/bash
gcc c.c -o c
gzip -c index.html > index.html.gz
tgt=camera_index.h
./c index.html.gz > $tgt
echo -ne "\n\n" >> $tgt
sed -n "/index_ov3660.html.gz/,/^};/p" ../camera_index.h >> $tgt
echo >> $tgt
mv $tgt ..
rm -f c d index.html.gz
