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
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
echo "*****************************************************************************************************************"
echo "***                                      NAS Copy Job                                                         ***"
echo "*****************************************************************************************************************"
echo "*"
echo "*   Run time: $(date) @ $(hostname)"
echo "*"

if ! test -f "./config.sh"; then
    echo "*"
    echo "*    ERROR: No config file found in '$SCRIPT_DIR'"
    echo "*    ----------------------------------------------------"
    echo "*"
    echo "*       Rename file 'config-example.sh' to 'config.sh'"
    echo "*       Make sure all configurations are set properly."
    echo "*       Poor settings may cause data loss!"
    echo "*"
    echo "*       Download latest script version and"
    echo "*       its 'config-example.sh' file from"
    echo "*       https://github.com/ohls/nas-copy-job"
    echo "*  "
    echo "*  "

    exit 1
    #^^^^^
fi

echo "*   PHOTO_SOURCE_PATH: $PHOTO_SOURCE_PATH"
echo "*   PHOTO_TARGET_PATH: $PHOTO_TARGET_PATH"
echo "*   DRYRUN: $DRYRUN"
echo "*"
echo "*"
echo "*"


echo "***  Make automated copy of recent photos ***********************************************************************"
echo "*****************************************************************************************************************"
# safely copy all JPEGs from PHOTO_SOURCE_PATH to PHOTO_TARGET_PATH ----------------------------------------------------
#    if is newer than DAYS_WHEN_PHOTO_TARGET_PATH_IS_OLD days.
#    delete files in the PHOTO_TARGET_PATH that are not in the PHOTO_SOURCE_PATH; delete ghosts
#    Debug info: --dry-run (n) in -axprvn # -v is verbose (a lot of output)
if [ "$DRYRUN" = true ] ; then
  rsync_options="-axprvn --delete"
else
  rsync_options="-axpr --delete"
fi

echo "*** Copy photos with flags $rsync_options"
find "$PHOTO_SOURCE_PATH" -type f \( -name '*.jpg' -o -name '*.JPG' \) -mtime -"$DAYS_WHEN_PHOTO_IS_OLD" -printf %P\\0| eval rsync "$rsync_options" --files-from=- --from0 "$PHOTO_SOURCE_PATH $PHOTO_TARGET_PATH"
echo ""

# delete files in PHOTO_TARGET_PATH that are older than DAYS_WHEN_PHOTO_TARGET_PATH_IS_OLD days
# ^^^^^^^^^^^^   this is tested, but dangerous
if [ "$DRYRUN" = true ] ; then
  echo "*** Dry-run: Delete photos in PHOTO_TARGET_PATH older than $DAYS_WHEN_PHOTO_IS_OLD days"
else
  echo "*** Delete photos in PHOTO_TARGET_PATH older than $DAYS_WHEN_PHOTO_IS_OLD days"
  find "$PHOTO_TARGET_PATH" -type f -mtime +"$DAYS_WHEN_PHOTO_IS_OLD" -exec rm -f {} \;
fi
echo ""

echo "***  Move and sort smart-phone photos  **************************************************************************"
echo "*****************************************************************************************************************"
# Sort and clean Smart Phone Camera photos -----------------------------------------------------------------------------
#   On the NAS folder that represent the synced/uploaded data from smart-phone
#   take all photos taken from camera, stored on Internal Memory and
#   after a few days delay to allow user clean up of "ugly" snap shots (set DAYS_TO_DELAY_MOBILE_PHOTOS)
#   move the photos to the SD-Card (representation on NAS) to free up expensive Internal Memory
#   into a yearly sub-folder.
#   Nothing will be done on the smart phone, only on the NAS (recommended at night)
#   Synology Drive can then sync the NAS folder with the smart-phone to actually do the operation on the smart-phone

YEAR_NOW=$(date +"%Y")
YEARS_AGO=$((YEAR_NOW-5))
YEAR_LAST=$(date --date="$DAYS_TO_DELAY_MOBILE_PHOTOS days ago" '+%Y')

# echo "This year is $YEAR_NOW"
# echo "Years ago was $YEARS_AGO"

if [ "$DRYRUN" = true ] ; then
  rsync_options="-axprvn --remove-source-files"
else
  # do not use --delete option here, because it is a move it may create data loss
  rsync_options="-axpr --remove-source-files"
fi


for user in ${USERS[@]}; do
  echo "* Sort $user's photos from Internal Memory to SD-Card into a yearly sub-folder (on its sync on NAS)"
  echo "*   rsync options $rsync_options"

  for (( y=YEARS_AGO; y<=YEAR_LAST; y++ ))
  do
    source_path="$HOMES_PATH/$user/$INTERNAL_MEMORY_DCIM_CAMERA_ON_NAS_FOLDER"
    target_path="$HOMES_PATH/$user/$SD_CARD_DCIM_CAMERA_ON_NAS_FOLDER/$y"
    first_day_in_year="$y-01-01 00:00:00"
    last_day_in_year="$y-12-31 23:59:59"
    if [ "$y" -eq "$YEAR_LAST" ]; then
      last_day_in_year=$(date --date="$DAYS_TO_DELAY_MOBILE_PHOTOS days ago" '+%Y-%m-%d 23:59:59')
    fi
    echo "*"
    echo "*   $y: Move photos modified between $first_day_in_year and $last_day_in_year"
    echo "*     from $source_path"
    echo "*     to   $target_path"

    # important to create the target folder if it doesn't exist.
    #   Otherwise rsync will take it as target file name and move all photos to the same file
    #   overwriting them and only the last photo remains with year as filename.
    #   DANGEROUS!!! In this case all photos (but the last per year) get deleted
    mkdir -p $target_path

    find "$source_path" -type f \( -name '*.jpg' -o -name '*.JPG' \) -newermt "$first_day_in_year" ! -newermt "$last_day_in_year" -printf %P\\0| eval rsync "$rsync_options" --files-from=- --from0 "$source_path $target_path"

  done

  echo "*"
  echo "*"

done

echo "*"
echo "*"
echo "*"
echo "*   Finished at run time: $(date)"
echo "*                                                                                                               *"
echo "*****************************************************************************************************************"

