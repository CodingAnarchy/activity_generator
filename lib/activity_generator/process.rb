require "sys/proctable"

module ActivityGenerator
  class Process
    attr_reader :pid, :data

    def initialize(cmd_path, *args)
      @pid = ::Process.spawn(cmd_path, *args, out: OS.dev_null, err: OS.dev_null)
      @data = Sys::ProcTable.ps(pid: pid)
    end

    def to_yaml

    end
  end
end
