#!/usr/bin/env bash

SOURCE_FILE=$1
BUILD_ENV_FILE=${2:-.buildenv}

BUILD_NUM_FILE=$SOURCE_FILE

if [[ -z "$SOURCE_FILE" ]];then
  # If there are no args, then we don't create a build number
  SKIP_BUILD_NUMBER=true
elif [[ "$SOURCE_FILE" == gs://* ]];then 
  # If the source file is a cloud storage link, download it
  echo "Copying build number file from $SOURCE_FILE"
  BUILD_NUM_FILE="/tmp/$(basename $SOURCE_FILE)"
  gsutil -q cp "${SOURCE_FILE}" "${BUILD_NUM_FILE}"

  if [ $? -ne 0 ];then
    echo "No remote build number file at $SOURCE_FILE"
  fi
else
  echo "Reading build number from $SOURCE_FILE"
fi

# Initialize the build env file.
if [ ! -f "$BUILD_ENV_FILE" ];then
  echo "#!/usr/bin/env bash" > "$BUILD_ENV_FILE"
  echo >> "$BUILD_ENV_FILE"
  echo >> "export CI=true" >> "$BUILD_ENV_FILE"
  echo >> "export BUILD_TIME=$(date -u +%Y-%m-%dT%H:%M:%S)" >> "$BUILD_ENV_FILE"
  
  chmod +x "$BUILD_ENV_FILE"
fi

# Increment the build number
if [[ -z $SKIP_BUILD_NUMBER ]];then
  OLD_BUILD_NUM=$(cat "$BUILD_NUM_FILE" || echo 0)
  BUILD_NUM=$(($OLD_BUILD_NUM + 1))

  echo "Incrementing build number: $OLD_BUILD_NUM => $BUILD_NUM"

  echo "$BUILD_NUM" > "$BUILD_NUM_FILE"
  if [[ "$SOURCE_FILE" != "$BUILD_NUM_FILE" ]];then
    echo "Uploading updated build number..."
    gsutil cp "${BUILD_NUM_FILE}" "${SOURCE_FILE}"
  fi

  echo "export BUILD_NUM=$BUILD_NUM" >> "$BUILD_ENV_FILE"
fi

echo "Build env file written to: `pwd`/$BUILD_ENV_FILE"
