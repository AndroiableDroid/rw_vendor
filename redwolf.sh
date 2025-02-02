#!/bin/bash

echo "-----------------Making RedWolf-----------------"

echo "-- Setting up Environment Variables"
if [ -z "$TW_DEVICE_VERSION" ]; then
RW_BUILD=Unofficial
else
RW_BUILD=$TW_DEVICE_VERSION
fi
RW_VENDOR=vendor/redwolf
RW_WORK=$OUT/RW_AIK
RW_2GB=$OUT/RW_2GB
RW_DEVICE=$(cut -d'_' -f2 <<<$TARGET_PRODUCT)

RW_OUT_NAME=RedWolf-$RW_BUILD-$RW_DEVICE

if [ -d "$RW_WORK" ]; then
  echo "-- Working Folder Found in OUT. Removing it."
  rm -rf "$RW_WORK"
fi

echo "-- Unpacking Recovery"
bash "$RW_VENDOR/tools/mkboot" "$OUT/recovery.img" "$RW_WORK" > /dev/null 2>&1

echo "-- Including WolfShit"
cp -R "$RW_VENDOR/prebuilt/WolfShit" "$RW_WORK/ramdisk/WolfShit"

echo "-- Repacking and Copying Recovery"
bash "$RW_VENDOR/tools/mkboot" "$RW_WORK" "$OUT/$RW_OUT_NAME.img" > /dev/null 2>&1
cd "$OUT" && md5sum "$RW_OUT_NAME.img" > "$RW_OUT_NAME.img.md5" && cd - > /dev/null 2>&1

if [ "$DEVICE_HAS_2GB_VARIANT" = "true" ]; then
  echo '-- 2GB Variant Found'
  rm -rf "$RW_2GB"
  mkdir "$RW_2GB"
  echo '-- Copying Files'
  mkdir -p "$RW_2GB/META-INF/com/google/android"
  cp "$RW_VENDOR/prebuilt/update-binary" "$RW_2GB/META-INF/com/google/android"
  cp -R "$RW_VENDOR/prebuilt/WolfShit" "$RW_2GB/tools"
  cp "$OUT/recovery.img" "$RW_2GB/tools"
  sed -i -- "s/devicenamehere/${RW_DEVICE}/g" "$RW_2GB/META-INF/com/google/android/update-binary"
  echo '-- Compressing Files to ZIP'
  cd "$RW_2GB" && zip -r "$OUT/$RW_OUT_NAME-2GB_RAM.zip" ./* > /dev/null 2>&1 && cd - > /dev/null 2>&1
  cd "$OUT" && md5sum "$RW_OUT_NAME-2GB_RAM.zip" > "$RW_OUT_NAME-2GB_RAM.zip.md5" && cd - > /dev/null 2>&1
fi

echo "------------Finished Making RedWolf-------------"
