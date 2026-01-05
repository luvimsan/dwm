#!/usr/bin/env bash

PATCHES=(
    "tabi3"
    "splitstatus"
    "pushnomaster"
    "scratchpad"
    "tag-apps"
    "center"
    "noborder"
    "bidi"
    "myconfig"
)

echo "Resetting stage to clean master..."
git switch -C stage master

for patch in "${PATCHES[@]}"; do
    echo "Merging $patch..."
    if ! git merge "$patch" --no-edit; then
        GIT_DIR=$(git rev-parse --git-dir)

        if [ -f "$GIT_DIR/MERGE_MSG" ]; then
            echo "Auto-resolved using previous resolution. Adding and continuing..."
            git add .
            git commit --no-edit
        else
            echo "Hard conflict detected in $patch! Please fix manually."
            exit 1
        fi
    fi
done

git switch prod || git switch -c prod
echo "Syncing prod with stage..."
git reset --hard stage

echo "Removing old config..."
doas rm -f config.h

echo "Compiling and installing..."
if doas make install clean; then
    printf "\ndwm has been compiled and installed successfully!\n"
else
    printf "\nBuild failed!\n"
    exit 1
fi

