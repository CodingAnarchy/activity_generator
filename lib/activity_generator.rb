require "activity_generator/version"
require "activity_generator/setup"
require "activity_generator/logging"
require "activity_generator/process_handler"
require "activity_generator/process_data"
require "activity_generator/process"
require "activity_generator/file_activity"
require "activity_generator/network_activity"

module ActivityGenerator
  class Error < StandardError; end
  # Your code goes here...

  class Runner
    def initialize(file: nil)
      file.present? ? run(file) : input_loop
    end

    def run(file)
      sequence = YAML.load_file(File.expand_path(file))
      sequence.each do |activity|
        case activity.keys.first
        when /process/ then run_process(activity["process"])
        when /file/ then file_activity(activity["file"])
        when /network/ then network_activity(activity["network"])
        end
      end
    end

    def input_loop

    end

    private

    def run_process(process_hash)
      Process.new(process_hash["path"], *process_hash["args"], distinct_log: true)
    end

    def file_activity(file_hash)
      action = file_hash.keys.first
      FileActivity.new(action, file_hash[action]["path"], file_type: file_hash[action]["type"])
    end

    def network_activity(network_hash)
      NetworkActivity.new(upload: network_hash["upload"], remote_addr: network_hash["address"], transmit_filepath: network_hash["path"])
    end
  end
end
