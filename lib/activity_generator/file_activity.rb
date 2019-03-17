require 'socket'

module ActivityGenerator
  class FileActivity
    include Logging
    include ProcessHandler
    attr_reader :file_path, :activity

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

    private

    def run
      case activity
      when /create/ then create_file
      when /modify/ then modify_file
      when /delete/ then delete_file
      end
      log(self)
    end

    def create_file
      if @file_type =~ /socket/
        UNIXServer.new(file_path) # Create the socket file
      else
        @process = Process.new(file_cmds[@file_type], file_path)
      end
    end

    def modify_file
      @process = Process.new('touch', file_path)
    end

    def delete_file
      @process = Process.new('rm', '-r', file_path)
    end

    def file_cmds
      {
        file: 'touch',
        dir: 'mkdir',
        pipe: 'mkfifo'
      }
    end
  end
end
