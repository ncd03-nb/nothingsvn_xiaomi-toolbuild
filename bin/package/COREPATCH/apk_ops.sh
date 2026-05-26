#!/usr/bin/env bash
work_dir=$(pwd)
# APK/JAR manipulation functions
TOOLS_DIR="$work_dir/bin/apktool"
WORK_DIR="$work_dir"
BACKUP_DIR="$WORK_DIR/backup"
SCRIPT_DIR="$work_dir/bin/package/COREPATCH"

decompile_apk() {
  local apk_file="$1"
  local base_name
  base_name="$(basename "$apk_file" .apk)"
  local output_dir="$WORK_DIR/${base_name}_decompile"

  echo "Decompiling $apk_file with apkeditor..."

  # Validate apk file before processing
  if [ ! -f "$apk_file" ]; then
    echo "Error: apk file $apk_file not found!"
    exit 1
  fi

  rm -rf "$output_dir"

  # Run apkeditor
  if ! java -jar "$TOOLS_DIR/apkeditor.jar" d -i "$apk_file" -o "$output_dir"; then
    echo "Error: Failed to decompile $apk_file with apkeditor"
    exit 1
  fi
}

recompile_apk() {
  local apk_file="$1"
  local base_name
  base_name="$(basename "$apk_file" .apk)"
  local output_dir="$WORK_DIR/${base_name}_decompile"
  local patched_apk="${base_name}_patched.apk"

  echo "Recompiling $apk_file with apkeditor..."

  # Check if decompiled directory exists
  if [ ! -d "$output_dir" ]; then
    echo "Error: Decompiled directory $output_dir not found!"
    echo "This means the decompilation step failed."
    exit 1
  fi

  java -jar "$TOOLS_DIR/redivision.jar" "$output_dir" apk

  # Run apkeditor
  if ! java -jar "$TOOLS_DIR/apkeditor.jar" b -i "$output_dir" -o "$patched_apk"; then
    echo "Error: Failed to recompile $output_dir with apkeditor"
    exit 1
  fi
}

backup_original_jar() {
  local jar_file="$1"
  local base_name
  base_name=$(basename "$jar_file" .jar)
  mkdir -p "$BACKUP_DIR/$base_name"
  # Save META-INF and res if present (silently ignore missing)
  unzip -o "$jar_file" "META-INF/*" "res/*" -d "$BACKUP_DIR/$base_name" > /dev/null 2>&1 || true
  # Also copy whole jar for safety
  cp -a "$jar_file" "$BACKUP_DIR/${base_name}.orig.jar"
  log "Backed up $jar_file -> $BACKUP_DIR/$base_name"
}

decompile_jar() {
  local jar_file="$1"
  local base_name
  base_name=$(basename "$jar_file" .jar)
  local output_dir="${WORK_DIR}/${base_name}_decompile"

  log "Decompiling $jar_file -> $output_dir (apktool)"
  rm -rf "$output_dir" "$base_name" > /dev/null 2>&1 || true
  mkdir -p "$output_dir"

  backup_original_jar "$jar_file"

  java -jar "${TOOLS_DIR}/apktool.jar" d -q -f "$jar_file" -o "$output_dir" || {
    err "apktool failed to decompile $jar_file"
    return 1
  }

  # copy META-INF and res into unknown/ (keeps resources for later)
  mkdir -p "$output_dir/unknown"
  cp -r "$BACKUP_DIR/$base_name/res" "$output_dir/unknown/" 2> /dev/null || true
  cp -r "$BACKUP_DIR/$base_name/META-INF" "$output_dir/unknown/" 2> /dev/null || true

  log "Decompile finished: $output_dir"

  # Provide compatibility symlinks for tools expecting smali_classes* paths
  # Map classes -> smali and classesN -> smali_classesN if not already present
  if [ -d "$output_dir/classes" ] && [ ! -e "$output_dir/smali" ]; then
    ln -s "classes" "$output_dir/smali" 2> /dev/null || true
  fi
  for n in 2 3 4 5 6 7 8 9; do
    if [ -d "$output_dir/classes${n}" ] && [ ! -e "$output_dir/smali_classes${n}" ]; then
      ln -s "classes${n}" "$output_dir/smali_classes${n}" 2> /dev/null || true
    fi
  done

  echo "$output_dir"
}

recompile_jar() {
  local jar_file="$1" # original jar file path (used only for name)
  local base_name
  base_name=$(basename "$jar_file" .jar)
  local output_dir="${WORK_DIR}/${base_name}_decompile"
  local patched_jar="${base_name}_patched.jar"

  log "Recompiling $output_dir -> $patched_jar"
  if [ ! -d "$output_dir" ]; then
    err "Recompile failed: decompile dir not found: $output_dir"
    return 1
  fi

  java -jar "$TOOLS_DIR/redivision.jar" "$output_dir" jar

  java -jar "${TOOLS_DIR}/apktool.jar" b -q -f "$output_dir" -o "$patched_jar" || {
    err "apktool build failed for $output_dir"
    return 1
  }

  java -jar "$TOOLS_DIR/timestamp.jar" "$patched_jar" 1199145600

  log "Created patched JAR: $patched_jar"
  echo "$patched_jar"
}
