#!/bin/sh
# Fast "pick one" reel: each photo sharp in the middle over a blurred copy of itself, hard cuts, end card.
set -e
PH=../reel-check-list-arrivee/photos
ORDER="5 7 4 6 1 2 3 8"; D=1.3; END=2.6; FPS=30; TOP=520
fr=$(awk "BEGIN{print int($D*$FPS)}")
in=""; f=""; n=0; k=0; cat=""
for p in $ORDER; do
  k=$((k+1))
  wh=$(ffprobe -v error -show_entries stream=width,height -of csv=p=0 $PH/$p.jpg)
  w=${wh%,*}; h=${wh#*,}; H=$(( (1080*h/w)/2*2 ))
  in="$in -loop 1 -framerate $FPS -t $D -i $PH/$p.jpg -i $PH/$p.jpg -loop 1 -framerate $FPS -t $D -i ov-$k.png"
  a=$n; b=$((n+1)); o=$((n+2)); n=$((n+3))
  f="$f[$a:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=28,eq=brightness=-0.10:saturation=0.9[bg$k];"
  f="$f[$b:v]scale=2160:-2,zoompan=z='1+0.0016*on':d=$fr:s=1080x$H:fps=$FPS:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'[fg$k];"
  f="$f[bg$k][fg$k]overlay=0:$TOP:shortest=1[c$k];[c$k][$o:v]overlay=0:0,setsar=1,format=yuv420p[v$k];"
  cat="$cat[v$k]"
done
k=$((k+1)); in="$in -loop 1 -framerate $FPS -t $END -i end.png"
f="$f[$n:v]setsar=1,format=yuv420p[v$k];"; cat="$cat[v$k]"; n=$((n+1))
f="$f${cat}concat=n=$k:v=1:a=0[out]"
ffmpeg -loglevel error -y $in -f lavfi -i anullsrc=r=44100:cl=stereo -filter_complex "$f" \
  -map "[out]" -map $n:a -shortest -c:v libx264 -preset slow -crf 18 -r $FPS -pix_fmt yuv420p \
  -c:a aac -b:a 128k -movflags +faststart reel-une-seule.mp4
