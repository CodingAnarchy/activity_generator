require "os"
require "fileutils"
require "securerandom"
require "net/http"
require "active_support/core_ext/string"
require "active_support/core_ext/hash"

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

PUBLIC_IP = Net::HTTP.get(URI("https://api.ipify.org"))

TEST_FILE = '/tmp/transmit_test_file'
open(TEST_FILE, 'w') { |f| f << SecureRandom.hex(250) } unless File.exists?(TEST_FILE)
