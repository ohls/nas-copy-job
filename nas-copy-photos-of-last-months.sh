#!/bin/bash

# Documentation --------------------------------------------------------------------------------------------------------
# See read.md for general explanation and comments below for details of the code

# Config ---------------------------------------------------------------------------------------------------------------
# set configuration in config.sh
. ./config.sh

# Notes ----------------------------------------------------------------------------------------------------------------
# Consider to use a special user to run this script.
#   Set the user permission in a way that he can not delete in the SOURCE_PATH but can delete in the TARGET_PATH
#   to give extra safety to prevent unintended data loss if the script goes wrong


# Code -----------------------------------------------------------------------------------------------------------------
echo "***********************************************************************"
echo "***                          NAS Copy Job                           ***"
echo "***********************************************************************"
echo "*"
echo "*   Run time: $(date) @ $(hostname)"
echo "*"
echo "*"
echo "*   PHOTO_SOURCE_PATH: $PHOTO_SOURCE_PATH"
echo "*   PHOTO_TARGET_PATH: $PHOTO_TARGET_PATH"
echo "*   DRYRUN: $DRYRUN"
echo ""
echo ""
# safely copy all JPEGs from PHOTO_SOURCE_PATH to PHOTO_TARGET_PATH
#    if is newer than DAYS_WHEN_PHOTO_TARGET_PATH_IS_OLD days.
#    delete files in the PHOTO_TARGET_PATH that are not in the PHOTO_SOURCE_PATH; delete ghosts
#    Debug info: --dry-run (n) in -axprvn # -v is verbose (a lot of output)
if [ "$DRYRUN" = true ] ; then
  rsync_options="-axprvn --delete"
  echo "*** Begin rsync copy photos with flags $rsync_options ***"
else
  rsync_options="-axpr --delete"
  echo "*** Begin rsync copy photos with flags $rsync_options ***"
fi

find "$PHOTO_SOURCE_PATH" -type f \( -name '*.jpg' -o -name '*.JPG' \) -mtime -"$DAYS_WHEN_PHOTO_IS_OLD" -printf %P\\0| eval rsync "$rsync_options" --files-from=- --from0 "$PHOTO_SOURCE_PATH $PHOTO_TARGET_PATH"
echo ""

# delete files in PHOTO_TARGET_PATH that are older than DAYS_WHEN_PHOTO_TARGET_PATH_IS_OLD days
# ^^^^^^^^^^^^   this is tested, but dangerous
if [ "$DRYRUN" = true ] ; then
  echo "*** Dry-run: Delete photos in PHOTO_TARGET_PATH older than $DAYS_WHEN_PHOTO_IS_OLD days ***"
else
  echo "*** Delete photos in PHOTO_TARGET_PATH older than $DAYS_WHEN_PHOTO_IS_OLD days ***"
  find "$PHOTO_TARGET_PATH" -type f -mtime +"$DAYS_WHEN_PHOTO_IS_OLD" -exec rm -f {} \;
fi
echo ""


YEAR_NOW=$(date +"%Y")
YEARS_AGO=$((YEAR_NOW-5))
echo "This year is $YEAR_NOW"
echo "Years ago was $YEARS_AGO"

for user in ${USERS[@]}; do
  echo "* Sort $user's photos from Internal Memory to SD-Card (in its sync on NAS)"

    for (( y=YEARS_AGO; y<=YEAR_NOW; y++ ))
    do
      echo "*   Begin rsync move photos of $y"
      echo "*     from $user/$INTERNAL_MEMORY_DCIM_CAMERA_ON_NAS"
      echo "*     to   $user/$SD_CARD_DCIM_CAMERA_ON_NAS/$y"
    done

done