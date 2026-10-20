#!/bin/sh
# Gallery reel: ivory frame with text, photo slowly zooming inside its 960x640 window, slide-left transitions.
# Columns: duration | photo (or - for none) | frame background
set -e
SEGS="2.8 photos/5.jpg frame-1.png
2.0 photos/7.jpg frame-2.png
2.0 photos/6.jpg frame-3.png
2.0 photos/1.jpg frame-4.png
2.0 photos/2.jpg frame-5.png
2.0 photos/3.jpg frame-6.png
2.0 photos/8.jpg frame-7.png
2.0 photos/4.jpg frame-8.png
3.4 - frame-9.png"
X=0.3; FPS=30; in=""; f=""; n=0; k=0
echo "$SEGS" | {
while read d ph bg; do
  k=$((k+1)); in="$in -loop 1 -framerate $FPS -t $d -i $bg"; b=$n; n=$((n+1))
  if [ "$ph" = "-" ]; then
    f="$f[$b:v]setsar=1,format=yuv420p[v$k];"
  else
    fr=$(awk "BEGIN{print int($d*$FPS)+1}")
    in="$in -i $ph"; p=$n; n=$((n+1))
    f="$f[$p:v]scale=1920:1280:force_original_aspect_ratio=increase,crop=1920:1280,zoompan=z='1+0.0022*on':d=$fr:s=960x640:fps=$FPS:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)'[p$k];[$b:v][p$k]overlay=60:420:shortest=1,setsar=1,format=yuv420p[v$k];"
  fi
  eval "d$k=$d"
done
prev=v1; off=$(awk "BEGIN{print $d1-$X}"); j=2
while [ $j -le $k ]; do
  eval "dj=\$d$j"
  f="$f[$prev][v$j]xfade=transition=slideleft:duration=$X:offset=$off[x$j];"
  prev=x$j; off=$(awk "BEGIN{print $off+$dj-$X}"); j=$((j+1))
done
ffmpeg -loglevel error -y $in -f lavfi -i anullsrc=r=44100:cl=stereo -filter_complex "${f%;}" \
  -map "[$prev]" -map $n:a -shortest -c:v libx264 -preset slow -crf 18 -r $FPS -pix_fmt yuv420p \
  -c:a aac -b:a 128k -movflags +faststart reel-check-list-arrivee.mp4
}
