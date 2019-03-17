require "activity_generator/version"
require "activity_generator/logger"
require "activity_generator/process_handler"
require "activity_generator/process_data"
require "activity_generator/process"
require "activity_generator/file_activity"
require "activity_generator/network_activity"
require "os"
require "securerandom"

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

TEST_FILE = '/tmp/transmit_test_file'
open(TEST_FILE, 'w') { |f| f << SecureRandom.hex(250) } unless File.exists?(TEST_FILE)

module ActivityGenerator
  class Error < StandardError; end
  # Your code goes here...
end
