require "activity_generator/version"
require "activity_generator/setup"
require "activity_generator/logging"
require "activity_generator/process_handler"
require "activity_generator/process_data"
require "activity_generator/process"
require "activity_generator/file_activity"
require "activity_generator/network_activity"

module ActivityGenerator
  class ActionComplete < StandardError; end
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
      print "Activity Request > "
      user_input = gets.chomp.split(" ")
      case user_input.first
      when /process/ then input_process(*user_input[1..-1])
      when /file/ then input_file(*user_input[1..-1])
      when /network/ then input_network(*user_input[1..-1])
      when /exit/ then return
      else
        raise ArgumentError.new("Incorrect input arguments. Expected one of:\n  process command_path [arg1] [arg2] ... [argN]\n  file create/modify/delete file_path [file_type: 'file'/'socket'/'dir'/'pipe']\n  network address [file path to upload]\n\nInput `exit` to quit.\n")
      end
      raise ActionComplete
    rescue ArgumentError => e
      puts e.to_s
      retry
    rescue ActionComplete
      retry
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
      NetworkActivity.new(remote_addr: network_hash["address"], transmit_filepath: network_hash["path"])
    end

    def input_process(path, *args)
      puts "Running #{path}..."
      process = run_process({path: path, args: args}.stringify_keys)
      puts "Started #{process.data.cmdline}..."
    end

    def input_file(action, path, file_type=nil)
      puts "Performing #{action} on #{path}..."
      file_activity({action => {path: path, type: file_type}.stringify_keys})
    end

    def input_network(address, upload_path=nil)
      puts "Connecting to #{address} and #{upload_path.present? ? 'transmitting' : 'receiving'} data..."
      network_activity({address: address, transmit_filepath: upload_path}.stringify_keys)
    end
  end
end
