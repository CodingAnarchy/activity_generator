module ActivityGenerator
  module Logging
    LOG_PATH = File.expand_path("~/log")
    FileUtils.mkdir_p(LOG_PATH)
    
    def to_yaml
      # Remove the leading triple-hyphen that separates docs: want it to be all one document
      # Bound it with a leading hyphen so the YAML dump interprets it as an element of a sequence
      "- #{to_hash.to_yaml[5..-1].indent(2, " ", true)}"
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
