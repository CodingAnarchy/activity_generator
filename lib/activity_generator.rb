require "activity_generator/version"
require "activity_generator/logger"
require "activity_generator/process_data"
require "activity_generator/process"
require "activity_generator/file_activity"
require "os"

if OS.linux?
  require 'linux_c_lib'
  stat_lines = File.open("/proc/stat").readlines
  BOOTTIME = catch(:boottime) do
    stat_lines.each do |line|
      split_line = line.split
      throw :boottime, split_line[1].to_i if split_line[0] == "btime"
    end
    nil
  end
end

module ActivityGenerator
  class Error < StandardError; end
  # Your code goes here...
end
