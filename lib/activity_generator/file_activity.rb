module ActivityGenerator
  class FileActivity
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
        UNIXSocket.new(file_path)
        @process_data = Sys::ProcTable.ps(pid: ::Process.pid) # Get process data for this process
      else
        @process_data = Process.new(file_cmds[@file_type], file_path).data
      end
    end

    def file_cmds
      {
        file: 'touch',
        dir: 'mkdir',
        pipe: 'mknod'
      }
    end

    def process_hash
      @process_data.to_hash
    end
  end
end
