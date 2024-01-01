#!/bin/bash

# Documentation --------------------------------------------------------------------------------------------------------
# See read.md for general explanation and comments below for details of the code

# Config ---------------------------------------------------------------------------------------------------------------
DAYS_WHEN_PHOTO_TARGET_PATH_IS_OLD=400
PHOTO_SOURCE_PATH="/volume1/Public/Photos"
PHOTO_TARGET_PATH="/volume1/Automatisierte-Kopien/Fotos-letzter-Monate"
# uncomment for testing
#PHOTO_SOURCE_PATH="/volume1/Public/Temp/copy-job-test/source"
#PHOTO_TARGET_PATH="/volume1/Public/Temp/copy-job-test/target"

# Notes ----------------------------------------------------------------------------------------------------------------
# Consider to use a special user to run this script.
#   Set the user permission in a way that he can not delete in the SOURCE_PATH but can delete in the TARGET_PATH
#   to give extra safety to prevent unintended data loss if the script goes wrong


# Code -----------------------------------------------------------------------------------------------------------------

# safely copy all JPEGs from PHOTO_SOURCE_PATH to PHOTO_TARGET_PATH
#    if is newer than DAYS_WHEN_PHOTO_TARGET_PATH_IS_OLD days.
#    delete files in the PHOTO_TARGET_PATH that are not in the PHOTO_SOURCE_PATH; delete ghosts
#    Dbug info: --dry-run (n) in -axprvn # -v is verbose (a lot of output)
find $PHOTO_SOURCE_PATH -type f \( -name '*.jpg' -o -name '*.JPG' \) -mtime -$DAYS_WHEN_PHOTO_TARGET_PATH_IS_OLD -printf %P\\0|rsync -axpr --delete --files-from=- --from0 $PHOTO_SOURCE_PATH $PHOTO_TARGET_PATH

# delete files in PHOTO_TARGET_PATH that are older than DAYS_WHEN_PHOTO_TARGET_PATH_IS_OLD days
# ^^^^^^^^^^^^   this is tested, but dangerous
find $PHOTO_TARGET_PATH -type f -mtime +$DAYS_WHEN_PHOTO_TARGET_PATH_IS_OLD -exec rm -f {} \;