(echo '['; sed -ne '/###############################START_OF_JSON/,/###############################END_OF_JSON/{/^###############################.*_OF_JSON/d;p}' < '/home/suzanne/00ligopam/ligo/_build/default/src/test/_build/_tests/'*'/Integration (End to End).001.output'; echo '"end of json"]') > /tmp/js.json
