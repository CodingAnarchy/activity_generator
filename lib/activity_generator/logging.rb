module ActivityGenerator
  module Logging
    LOG_PATH = File.expand_path("~/log")
    FileUtils.mkdir_p(LOG_PATH)
    
    def to_yaml
      to_hash.to_yaml
    end

    def log(event)
      @logfile ||= "#{LOG_PATH}/activity_generator_#{::Process.pid}.log"
      open(@logfile, "a") do |f|
        f << event.to_yaml
        f << "\n"
      end
    end
  end
end
