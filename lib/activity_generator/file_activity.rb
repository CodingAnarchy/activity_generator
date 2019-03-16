require 'socket'

module ActivityGenerator
  class FileActivity
    attr_reader :file_path, :activity, :process_data

    def initialize(activity_type, file_path, **options)
      @file_path = File.expand_path(file_path)
      @activity = activity_type
      @file_type = options[:file_type]&.to_sym || :file
      run
    end

    def to_hash
      {
        file: {
          path: file_path,
          activity: activity,
        }.merge(process_hash)
      }
    end

    def to_yaml
      to_hash.to_yaml
    end

    private

    def run
      case activity
      when /create/ then create_file
      when /modify/
      when /delete/
      end
    end

    def create_file
      if @file_type =~ /socket/
        UNIXServer.new(file_path) # Create the socket file
        @process_data = ProcessData.new(Sys::ProcTable.ps(pid: ::Process.pid)) # Get process data for this process
      else
        @process_data = ProcessData.new(Process.new(file_cmds[@file_type], file_path).data)
      end
    end

    def file_cmds
      {
        file: 'touch',
        dir: 'mkdir',
        pipe: 'mkfifo'
      }
    end

    def process_hash
      @process_data.to_hash
    end
  end
end
