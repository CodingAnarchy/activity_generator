require "sys/proctable"

module ActivityGenerator
  class Process
    attr_reader :pid, :data

    def initialize(cmd_path, *args)
      @pid = ::Process.spawn(cmd_path, *args, out: "/dev/null", err: "/dev/null")
      @data = Sys::ProcTable.ps(pid: pid)
    end

    def log
    end
  end
end
