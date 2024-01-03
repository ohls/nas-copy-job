# ======================================================================================================================
# Enter all your personal configuration and make sure to not add it to your git repo
#   this way you can have different configurations on your test folder and your real job folder
#   and you keep your personal data out of your (public) repo
# ======================================================================================================================


# General --------------------------------------------------------------------------------------------------------------
# Do a dry-run without moving files around, boolean true/false (no quotes)
DRYRUN=true



# Path for automated photo copies. -------------------------------------------------------------------------------------
#   Recommended to use a "Team Folder" of Synology Drive to sync with multiple user PCs

# Automated copy of photos will be done of photos that are newer than DAYS_WHEN_PHOTO_IS_OLD in days
DAYS_WHEN_PHOTO_IS_OLD=400

#   Path to the source folder to generate automated copies of photos (no trailing slash/)
PHOTO_SOURCE_PATH="/volume1/Test/Source/Photos"

#   Path to the target folder to receive automated copies of photos (no trailing slash/)
PHOTO_TARGET_PATH="/volume1/Test/Target/Automated-Copies/photos-recent-of-months"



# Sort photos from Internal Memory to SD-Card --------------------------------------------------------------------------

# Only photos older than DAYS_TO_DELAY_MOBILE_PHOTOS days will be moved from Internal Memory to SD-Card
DAYS_TO_DELAY_MOBILE_PHOTOS=14

# List of usernames where photos shall be moved from Internal-Memory to SD-Card
USERS=("Tim" "Jill")

# Path to the root of the homes folder of Synology NAS (no trailing slash/)
HOMES_PATH="/volume1/Test/homes"

# Folder inside home of user that represents the sync of photos of the users smart-phone
#   no leading /slash, no trailing slash/
#   this is the part of the path that follows HOMES_PATH/USERNAME

# Internal Memory Folder (not path), synced folder of smart phone on NAS
INTERNAL_MEMORY_DCIM_CAMERA_ON_NAS_FOLDER="Handy-Sync/Internal-Memory/DCIM/Camera"

# SD-Card Folder (not path), synced folder of smart phone on NAS
SD_CARD_DCIM_CAMERA_ON_NAS_FOLDER="Handy-Sync/SD-Card/DCIM/Camera"