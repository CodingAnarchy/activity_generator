module ActivityGenerator
  module ProcessHandler
    def process_data
      @process.present? ? @process.data : ProcessData.new(Sys::ProcTable.ps(pid: ::Process.pid))
    end

    def process_hash
      process_data.to_hash
    end
  end
end
