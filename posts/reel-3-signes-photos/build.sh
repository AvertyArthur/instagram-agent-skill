#!/bin/sh
# Photo reel: each card = one photo panning sideways under its text panel, cross-faded.
# Columns: duration | photo | pan start x | pan end x | overlay | scaled height | crop y
set -e
SEGS="3.2 photos/4.jpg 1000 1250 ov-1.png 2300 380
3.0 photos/1.jpg 1300 1650 ov-2.png 1920 0
3.0 photos/3.jpg 1200 1550 ov-3.png 1920 0
3.2 photos/2.jpg 150 550 ov-4.png 1920 0
3.0 photos/4.jpg 1500 1780 ov-5.png 1920 0
3.4 end.png 0 0 - 1920 0"
X=0.4; FPS=30; in=""; f=""; n=0; k=0
echo "$SEGS" | {
while read d img x0 x1 ov h y; do
  in="$in -loop 1 -framerate $FPS -t $d -i $img"; bg=$n; n=$((n+1)); k=$((k+1))
  if [ "$ov" = "-" ]; then
    f="$f[$bg:v]scale=1080:1920,setsar=1,format=yuv420p[v$k];"
  else
    in="$in -loop 1 -framerate $FPS -t $d -i $ov"; o=$n; n=$((n+1))
    f="$f[$bg:v]scale=-2:$h,crop=1080:1920:'$x0+($x1-$x0)*t/$d':$y,setsar=1[b$k];[b$k][$o:v]overlay=0:0,format=yuv420p[v$k];"
  fi
  eval "d$k=$d"
done
prev=v1; off=$(awk "BEGIN{print $d1-$X}"); j=2
while [ $j -le $k ]; do
  eval "dj=\$d$j"
  f="$f[$prev][v$j]xfade=transition=fade:duration=$X:offset=$off[x$j];"
  prev=x$j; off=$(awk "BEGIN{print $off+$dj-$X}"); j=$((j+1))
done
ffmpeg -loglevel error -y $in -f lavfi -i anullsrc=r=44100:cl=stereo -filter_complex "${f%;}" \
  -map "[$prev]" -map $n:a -shortest -c:v libx264 -preset slow -crf 18 -r $FPS -pix_fmt yuv420p \
  -c:a aac -b:a 128k -movflags +faststart reel-3-signes-photos.mp4
}
