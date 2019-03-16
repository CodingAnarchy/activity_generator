require "sys/proctable"

module ActivityGenerator
  class Process
    attr_reader :pid, :data

    def initialize(cmd_path, *args)
      @pid = ::Process.spawn(cmd_path, *args, out: OS.dev_null, err: OS.dev_null)
      @data = Sys::ProcTable.ps(pid: pid)
    end

    def to_yaml
      { 
        process: {
          timestamp: start_time,
          username: Etc.getpwuid(data.uid).name,
          name: data.name,
          cmdline: data.cmdline,
          pid: pid
        }
      }.to_yaml
    end

    def start_time
      return data.start_tvsec if OS.osx?
      return linux_start if OS.linux?
      nil # Default - can't compute the start time for the process on this OS
    end

    private

    def linux_start
      return nil unless OS.linux? # Guard against using this if the system is not Linux
      data.starttime/LinuxCLib::hz + boottime
    end
  end
end
