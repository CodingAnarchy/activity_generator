module ActivtyGenerator
  class Logger
    LOG_PATH = File.expand_path("~/log")

    def initialize
      FileUtils.mkdir_p(LOG_PATH)
      @logfile = File.open(LOG_PATH.join("activity_generator_#{Time.now.to_i}.log"), 'w')
    end

    def log_event(event)
      @logfile.write(event.to_yaml)
    end
  end
end
