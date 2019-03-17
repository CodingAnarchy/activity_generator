module ActivityGenerator
  class ProcessData
    attr_reader :proc_table

    def initialize(proc_table)
      @proc_table = proc_table
    end
    
    def to_hash
      {
        process: {
          timestamp: start_time,
          username: Etc.getpwuid(proc_table.uid).name,
          name: proc_table.name,
          cmdline: proc_table.cmdline,
          pid: proc_table.pid
        }
      }
    end

    def start_time
      return proc_table.start_tvsec if OS.osx?
      return linux_start if OS.linux?
      nil # Default - can't compute the start time for the process on this OS
    end

    private

    def linux_start
      return nil unless OS.linux? # Guard against using this if the system is not Linux
      proc_table.starttime/LinuxCLib::hz + BOOTTIME
    end

    def method_missing(m, *args, &block)
      if self.to_hash[:process].keys.include?(m)
        self.to_hash[:process][m]
      else
        super
      end
    end
  end
end
