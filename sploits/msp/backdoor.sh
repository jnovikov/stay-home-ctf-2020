#!/usr/bin/env bash

url="$1:5001"

newcraft=$(curl -s $url/launch/ -d '{"phase": 0, "height": 5000, "antenna_focus": 0.2, "narrow_beam_response": "ping", "mass": 100}')
source=$(echo "$newcraft" | jq .id -r)
sx=$(echo "$newcraft" | jq .position[0] -r)
sy=$(echo "$newcraft" | jq .position[1] -r)

curl -s $url/tm/health | jq .stats[] -r | while read target; do

  # find target coords
  coords=$(curl -s $url/telemetry/$target | jq '(.object.position[0]|tostring) + " " + (.object.position[1]|tostring)' -r)
  tx=$(echo "$coords" | cut -d' ' -f1)
  ty=$(echo "$coords" | cut -d' ' -f2)

  echo "TARGET $target ($tx, $ty)"

  if [[ "$tx" == null ]] || [[ "$ty" == "null" ]]; then
    continue
  fi

  echo "SOURCE $source ($sx, $sy)"

  # return degrees(atan2(source_pos_x-target_pos_x, source_pos_y-target_pos_y) + PI);

  angle=$(python -c "import math; print(math.degrees(math.atan2($sx-$tx, $sy-$ty) + math.pi))")
  focus=$(python -c "import math; print(math.sqrt(sum((x - y) ** 2 for (x, y) in [($sx, $sy), ($tx, $ty)])) * 0.9)")
  #focus=0

  echo "BEAM $angle $focus"

  curl -s $url/beam/$source -d '{"angle": '$angle', "focus": '$focus'}' | jq .responses[] -r

done
