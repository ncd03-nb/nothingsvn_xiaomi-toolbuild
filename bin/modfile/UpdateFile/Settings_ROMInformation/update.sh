WORK_DIR=$(pwd)
source $WORK_DIR/functions.sh
MAIN_FOLDER="$WORK_DIR/build/baserom/images"
rom_os=$(cat $WORK_DIR/bin/ddevice/rom_os.txt)
AndroidVER=$(cat $WORK_DIR/bin/ddevice/androidver.txt)
APKEDITOR="java -jar $WORK_DIR/bin/apktool/apke.jar"
base_rom_code=$(cat $WORK_DIR/bin/ddevice/base_rom_code.txt)
myversion="$(cat $WORK_DIR/Version)"
repS="python3 $WORK_DIR/bin/strRep.py"

#patching
if [[ $rom_os == "MIUI" ]]; then 

mods "Add ROM Information To MIUI"
  mkdir -p $WORK_DIR/apk_temp
  isSettingsDIR=$(find "$MAIN_FOLDER" -type d -name "Settings")
  isSettings=$(find "$MAIN_FOLDER" -type f -name "Settings.apk")

  $APKEDITOR d -i $isSettings -o $WORK_DIR/apk_temp/isSettings.apk.out >/dev/null 2>&1
  p1=$(find "$WORK_DIR/apk_temp/isSettings.apk.out" -type f -name MiuiAboutPhoneUtils.smali)

  sed -i "s/MIUI /MIUINT $myversion | /g" $p1
  sed -i "s/MIUI Pad /MIUINT $myversion | /g" $p1
  sed -i "s/MIUI Fold /MIUINT $myversion | /g" $p1

  mods "Rebuild..."
  Settings=$(basename $isSettings)
  $APKEDITOR b -f -i $WORK_DIR/apk_temp/isSettings.apk.out -o $WORK_DIR/apk_temp/final/$Settings >/dev/null 2>&1

  if [ -f "$WORK_DIR/apk_temp/final/$Settings" ]; then
    mods "Cleaning WorkSpace"
    rm -rf $isSettingsDIR/*
    mods "Finish Modding"
    cp -rf $WORK_DIR/apk_temp/final/$Settings $isSettingsDIR
    mods "Cleaned!"
  
  fi

  rm -rf $WORK_DIR/apk_temp
  mods "Adding MIUI Information Done!"
else

mods "Add ROM Information To HyperOS"
  mkdir -p $WORK_DIR/apk_temp
  isSettingsDIR=$(find "$MAIN_FOLDER" -type d -name "Settings")
  isSettings=$(find "$MAIN_FOLDER" -type f -name "Settings.apk")
  $APKEDITOR d -i $isSettings -o $WORK_DIR/apk_temp/isSettings.apk.out >/dev/null 2>&1
  p1=$(find "$WORK_DIR/apk_temp/isSettings.apk.out" -type f -name MiuiAboutPhoneUtils.smali)
  tar1="$WORK_DIR/bin/modfile/UpdateFile/Settings_ROMInformation/getMiuiVersionInCard.ini"
  tar2="$WORK_DIR/bin/modfile/UpdateFile/Settings_ROMInformation/getOSVersionCode.ini"
  tar3="$WORK_DIR/bin/modfile/UpdateFile/Settings_ROMInformation/getRoXmsVersion.ini"
  tar4="$WORK_DIR/bin/modfile/UpdateFile/Settings_ROMInformation/getXmsVersion.ini"
  my="$WORK_DIR/build/baserom/images/system/system/build.prop"

  final_version="${base_rom_code%.*}"

  $repS $tar1 $p1
  $repS $tar2 $p1
  $repS $tar3 $p1
  $repS $tar4 $p1

  echo "ro.nothings.version=NothingsOOS $final_version | $base_rom_code" >> $my
  echo "ro.nothings.incremental=${final_version}.OOS" >> $my

  mods "Rebuild..."
  Settings=$(basename $isSettings)
  $APKEDITOR b -f -i $WORK_DIR/apk_temp/isSettings.apk.out -o $WORK_DIR/apk_temp/final/$Settings >/dev/null 2>&1

  if [ -f "$WORK_DIR/apk_temp/final/$Settings" ]; then
    mods "Cleaning WorkSpace"
    rm -rf $isSettingsDIR/*
    mods "Finish Modding"
    cp -rf $WORK_DIR/apk_temp/final/$Settings $isSettingsDIR
    mods "Cleaned!"
  
  fi

  rm -rf $WORK_DIR/apk_temp
  mods "Adding OS1/OS2 Information Done!"

fi