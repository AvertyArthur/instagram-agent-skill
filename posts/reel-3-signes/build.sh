#!/bin/sh
# Assemble the cards into a 1080x1920 reel: slow push-in on each card, short cross-fades.
set -e
D="3.0 2.8 2.8 3.0 2.8 3.4"; X=0.35; FPS=30
in=""; f=""; i=0
for d in $D; do
  i=$((i+1)); n=$(awk "BEGIN{print int($d*$FPS)}")
  in="$in -i card-$i.png"
  f="$f[$((i-1)):v]scale=2160:3840,zoompan=z='1+0.00045*on':d=$n:s=1080x1920:fps=$FPS:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',setsar=1,format=yuv420p[v$i];"
done
prev=v1; off=0; k=1
for d in $D; do
  [ $k -eq 1 ] && { off=$(awk "BEGIN{print $d-$X}"); k=2; continue; }
  f="$f[$prev][v$k]xfade=transition=fade:duration=$X:offset=$off[x$k];"
  prev=x$k; off=$(awk "BEGIN{print $off+$d-$X}"); k=$((k+1))
done
ffmpeg -loglevel error -y $in -f lavfi -i anullsrc=r=44100:cl=stereo -filter_complex "${f%;}" \
  -map "[$prev]" -map 6:a -shortest -c:v libx264 -preset slow -crf 18 -r $FPS -pix_fmt yuv420p \
  -c:a aac -b:a 128k -movflags +faststart reel-3-signes.mp4
