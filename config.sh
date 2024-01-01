# Rename this file to config.sh then:
# Enter all your personal configuration and make sure to not add it to your git repo
#   this way you can have different configurations on your test folder and your real job folder
#   and you keep your personal data out of your (public) repo
#
# Change DRYRUN to false to get files moved, everything else is just a dry-run
DRYRUN=true
DAYS_WHEN_PHOTO_IS_OLD=12
DAYS_TO_DELAY_MOBILE_PHOTOS=14
USERS=("Tim" "Jill")

PHOTO_SOURCE_PATH="/volume1/Public/Temp/copy-job-test/source"
PHOTO_TARGET_PATH="/volume1/Public/Temp/copy-job-test/target"

INTERNAL_MEMORY_DCIM_CAMERA_ON_NAS="/volume1/Test/copy-job-test/Internal-Memory/DCIM/Camera"
SD_CARD_DCIM_CAMERA_ON_NAS="/volume1/Test/copy-job-test/SD-Card/DCIM/Camera"