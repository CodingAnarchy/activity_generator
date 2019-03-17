require "os"
require "securerandom"
require "net/http"

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

# Monkey-patch string to indent (taken from ActiveSupport)
class String
  # Same as +indent+, except it indents the receiver in-place.
  #
  # Returns the indented string, or +nil+ if there was nothing to indent.
  def indent!(amount, indent_string = nil, indent_empty_lines = false)
    indent_string = indent_string || self[/^[ \t]/] || " "
    re = indent_empty_lines ? /^/ : /^(?!$)/
    gsub!(re, indent_string * amount)
  end

  # Indents the lines in the receiver:
  #
  #   <<EOS.indent(2)
  #   def some_method
  #     some_code
  #   end
  #   EOS
  #   # =>
  #     def some_method
  #       some_code
  #     end
  #
  # The second argument, +indent_string+, specifies which indent string to
  # use. The default is +nil+, which tells the method to make a guess by
  # peeking at the first indented line, and fallback to a space if there is
  # none.
  #
  #   "  foo".indent(2)        # => "    foo"
  #   "foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
  #   "foo".indent(2, "\t")    # => "\t\tfoo"
  #
  # While +indent_string+ is typically one space or tab, it may be any string.
  #
  # The third argument, +indent_empty_lines+, is a flag that says whether
  # empty lines should be indented. Default is false.
  #
  #   "foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
  #   "foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
  #
  def indent(amount, indent_string = nil, indent_empty_lines = false)
    dup.tap { |_| _.indent!(amount, indent_string, indent_empty_lines) }
  end
end
