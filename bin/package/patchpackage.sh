work_dir=$(pwd)
source $work_dir/functions.sh

mods "Add Package..."
TARGET_DIR="$work_dir/bin/package/"
noexecute=( "mkf2fsuserimg" "Penguin13" "patchMIUIFramework" "patchMIUIServices" "PowerKeeper" "RUN" "Penguin14" "Penguin15" "Penguin16" "patchpackage" "patcher_a16" "helper" "apk_ops" "logging" "patching" "tools" "kaorios_patches" "patcher" "fakelock_patch" "jar_patcher_a13" 
"jar_patcher_a14" "jar_patcher_a15" "jar_patcher_a16" )

find "$TARGET_DIR" -type f -name "*.sh" | while read -r script; do
    base="$(basename "$script" .sh)"

    skip=false
    for ex in "${noexecute[@]}"; do
        if [[ "$base" == "$ex" ]]; then
            skip=true
            break
        fi
    done

    if [[ $skip == false ]]; then
        bash "$script"
    fi
done