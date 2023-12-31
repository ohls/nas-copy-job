#!/usr/bin/env ruby

# gem install file-find
require 'file-find' # https://rubygems.org/gems/file-find
# gem install fileutils
require 'fileutils' # https://rubygems.org/gems/fileutils
# gem install timerizer
require 'Timerizer' # https://rubygems.org/gems/timerizer
# gem install exif
#require 'exif' # https://github.com/tonytonyjan/exif

# CONFIG ----------------------------------------------------------------
SOURCE_PATH = 'C:/Temp/copy-job-test/source'
PHOTO_TARGET_PATH = 'C:/Temp/copy-job-test/target'
VIDEO_TARGET_PATH = 'C:/Temp/copy-job-test/videos'
LOG_FILE_PATH = 'C:/Temp/copy-job-test/target/nas-copy-job.log'
SINGLE_JOB_DETAILED_LOG_FILE_PATH = 'C:/Temp/copy-job-test/target/nas-copy-last-job-details.log'
RELEVANT_FILE_EXTENSIONS = ['.jpeg', '.jpg', '.mov', '.mp4']
TIME_WHEN_FILE_IS_OLD = 50.month.ago
NOOP_BOOL = false # noop = No Operation --> if set to true all file operations will only by simulated but not really excuted
START_TIME = Time.now

class FileStatPlus
  attr_reader :filename, :mtime, :is_old, :is_new, :birthtime, :size, :basename, :extname, :extension, :subfolder, :ftype,
              :type, :is_photo, :is_video, :source_folder, :target_folder, :target_path, :is_target_identical
  def initialize(filepath)
    #puts "Create relevant file object #{filepath}"
    file_temp = File.stat(filepath)

    @filename      = filepath
    @mtime         = file_temp.mtime
    @is_old        = @mtime <  TIME_WHEN_FILE_IS_OLD
    @is_new     = @mtime >= TIME_WHEN_FILE_IS_OLD
    @birthtime     = file_temp.birthtime
    @size          = file_temp.size
    @basename      = File.basename(filepath)
    @source_folder = File.dirname(filepath)
    @extname       = File.extname(filepath)
    @extension     = File.extname(filepath).downcase
    @dirname       = File.dirname(filepath)
    @subfolder     = @dirname.gsub(SOURCE_PATH, "") # only the subfolder, relative to the source path, in order to create the subfolder in the target
    @ftype         = File.ftype(filepath) # https://ruby-doc.org/core-2.5.1/File.html#method-c-ftype
    @type          = "other"
    @is_photo      = false
    @is_video      = false

    target_elements = PHOTO_TARGET_PATH.split("/")
    subfolder_elements = @subfolder.split("/")
    @target_folder = target_elements.join("/") + subfolder_elements.join("/")
    @target_path = "#{@target_folder}/#{@basename}"


    if @extension == ".jpg" || @extension == '.jpeg'
      @type  = 'image'
      @is_photo = true
    elsif @extension == ".mp4" || @extension == '.mov'
      @type = 'video'
      @is_video = true
      @target_folder = VIDEO_TARGET_PATH + subfolder_elements.join("/")
      @target_path = "#{@target_folder}/#{@basename}"
    end

    @is_target_identical = check_if_target_identical

  end

  def check_if_target_identical
    identical = false
    if File.exist?(self.target_path)
      identical = FileUtils.compare_file(@filename, @target_path)
    end

    return identical
  end

end


files_relevant = []

rule = File::Find.new(
  :pattern => '*',
  :follow  => false,
  :path    => SOURCE_PATH
)

rule.find{ |f|
  file_info = File.stat(f)
  if file_info.file? && RELEVANT_FILE_EXTENSIONS.include?(File.extname(f).downcase)
    files_relevant.push( FileStatPlus.new(f) )
  end
}

log_file = File.new(LOG_FILE_PATH, "a")

errors = []
detailed_logs = []
photos_copied = []
photos_cleaned = []
videos_moved = []

files_relevant.each do |f|
  if f.is_video
    # Video files shall be moved from photo folder to video folder on NAS
    if f.is_target_identical
      detailed_logs.push("#{Time.now} - LOG: Delete video #{f.filename}, because identical with #{f.target_path}")
      FileUtils.remove_file(f.filename)
    else
      detailed_logs.push("#{Time.now} - LOG: Copy video #{f.filename} to #{f.target_folder}")
      FileUtils.mkdir_p(f.target_folder, :noop => NOOP_BOOL)
      FileUtils.cp(f.filename, f.target_path, :preserve => true, :noop => NOOP_BOOL)
      videos_moved.push(f)
    end
  end

  if f.is_photo && !f.is_target_identical && f.is_new
    # Copy photos from source to target if they are newer than the TIME_WHEN_FILE_IS_OLD
    detailed_logs.push("#{Time.now} - LOG: Copy photo #{f.filename} to #{f.target_folder}")
    FileUtils.mkdir_p(f.target_folder, :noop => NOOP_BOOL)
    FileUtils.cp(f.filename, f.target_folder, :preserve => true, :noop => NOOP_BOOL)
    photos_copied.push(f)
  end

  #TODO: This needs to go in a loop over all files in target. Right now it is looping over source
  if File.exist?(f.target_path)
    # clean up old photos and left over photos
    if f.is_photo && f.is_old
      # If the photo is old it shall be deleted, even if it is not existing at the source
      # photos could be deleted purposefully at the source
      detailed_logs.push("#{Time.now} - LOG: Deleted photo #{f.target_path} because it is old")
      FileUtils.rm(f.target_path, :noop => NOOP_BOOL)
      photos_cleaned.push(f.target_path)
    end

    if f.is_photo && !File.exist?(f.filename)
      # Delete photos that are not existing at the source
      # photos that are purposefully deleted at the source should not have ghost copies at the target folder
      detailed_logs.push("#{Time.now} - LOG: Deleted photo #{f.target_path} because the source is not identical")
      FileUtils.rm(f.target_path, :noop => NOOP_BOOL)
      photos_cleaned.push(f.target_path)
    end
  end

  #puts "Relevant file #{f.inspect}"
end

#TODO: Remove empty folder in photo target folder
total_job_time_seconds = Time.now - START_TIME
log_message = "#{Time.now} - LOG: Considered #{files_relevant.length} files in #{total_job_time_seconds.round(1)} seconds. #{errors.length} errors, #{photos_copied.length} photos copied, #{photos_cleaned.length} photos cleaned, #{videos_moved.length} videos moved\n"
log_file.write log_message
log_file.close

detailed_log_file = File.new(SINGLE_JOB_DETAILED_LOG_FILE_PATH, "w")
detailed_log_file.write(detailed_logs.join("\n"))
detailed_log_file.write("\n")
detailed_log_file.write(log_message)
detailed_log_file.close

exit 0