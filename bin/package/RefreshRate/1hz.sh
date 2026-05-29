work_dir=$(pwd)
source $work_dir/functions.sh
gfFile="$work_dir/build/baserom/images/product/etc/device_features/*.xml"
checkfps='<bool name="support_smart_fps">true</bool>'


if [ `grep -c "$checkfps" $gfFile` -eq '0' ];then
    for gfFile in $gfFile; do
    mods "Adding SmartFPS..."
    sed '/<integer name="defaultFps">60<\/integer>/a\    <bool name="support_smart_fps">true<\/bool>\<integer name="smart_fps_value">120<\/integer>' $gfFile > ${gfFile}.new
    mv ${gfFile}.new $gfFile
    done
    mods "Added SmartFPS"
else
    mods "Already have SmartFPS"
fi

mods "Adding more refresh rates..."
for i in "$gfFile"; do
  [ -f "$i" ] || continue
  grep -q '<item>120</item>' "$i" || sed -i '/<item>144<\/item>/a\        <item>120<\/item>' "$i"
  grep -q '<item>90</item>' "$i" || sed -i '/<item>120<\/item>/a\        <item>90<\/item>' "$i"
  grep -q '<item>1</item>' "$i" || sed -i '/<item>60<\/item>/a\        <item>1<\/item>' "$i"
  sed -i 's/>CN</>ALL</g' "$i"
  grep -q '<bool name="support_aod_fullscreen">true</bool>' "$i" || sed -i '/<\/features>/i\    <bool name="support_aod_fullscreen">true<\/bool>' "$i"
done
mods "Done"