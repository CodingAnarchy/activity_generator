require "sys/proctable"

module ActivityGenerator
  class Process
    include Logging
    attr_reader :pid, :data, :output

    def initialize(cmd_path, *args, record_output: false, distinct_log: false)
      output_read, output_write = IO.pipe if record_output # Don't open the pipe if we are not going to use it
      @pid = ::Process.spawn(cmd_path, *args, out: record_output ? output_write : OS.dev_null, err: OS.dev_null)
      @data = ProcessData.new(Sys::ProcTable.ps(pid: pid))
      if record_output
        ::Process.wait(pid)
        output_write.close
        @output = output_read.read
        output_read.close
      end
      log(self) if distinct_log
    end

    def to_hash
      @data.to_hash
    end
  end
end
