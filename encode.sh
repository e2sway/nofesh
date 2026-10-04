#!/bin/bash
set -euo pipefail

# Nofesh clip encoder — Stage 3 of cookbook v2.3.
# Takes raw Kling/Veo takes from _generation/raw/ and produces the mp4 files
# the app expects in Sources/Content/Resources/.
#
# Usage:
#   ./encode.sh                 # encode all 5 raw takes
#   ./encode.sh chin-tuck       # encode a single take

RESOURCES="Sources/Content/Resources"
RAW="_generation/raw"
mkdir -p "$RESOURCES"

# map:  argument-name -> rawfile -> finalfile
encode() {
  local name="$1" raw="$2" out="$3"
  if [ ! -f "$RAW/$raw" ]; then
    echo "skip: missing $RAW/$raw"
    return 0
  fi
  echo "encode: $RAW/$raw -> $RESOURCES/$out"
  ffmpeg -y -hide_banner -loglevel error \
    -i "$RAW/$raw" \
    -an \
    -c:v libx264 -crf 18 -pix_fmt yuv420p \
    "$RESOURCES/$out"
}

if [ $# -ge 1 ]; then
  case "$1" in
    chin-tuck) encode chin-tuck raw_chin_tuck.mp4 chin-tuck.mp4 ;;
    spinal-decompression) encode decompression raw_decompression.mp4 spinal-decompression.mp4 ;;
    hip-flexor) encode hip-flexor raw_hip_flexor.mp4 hip-flexor.mp4 ;;
    pelvic-tilt) encode pelvic-tilt raw_pelvic_tilt.mp4 pelvic-tilt.mp4 ;;
    glute-squeeze) encode glute-squeeze raw_glute_squeeze.mp4 glute-squeeze.mp4 ;;
    *) echo "unknown clip: $1"; exit 1 ;;
  esac
else
  encode chin-tuck        raw_chin_tuck.mp4        chin-tuck.mp4
  encode decompression    raw_decompression.mp4    spinal-decompression.mp4
  encode hip-flexor       raw_hip_flexor.mp4       hip-flexor.mp4
  encode pelvic-tilt      raw_pelvic_tilt.mp4      pelvic-tilt.mp4
  encode glute-squeeze    raw_glute_squeeze.mp4    glute-squeeze.mp4
fi

echo "done."