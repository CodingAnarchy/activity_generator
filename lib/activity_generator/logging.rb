module ActivityGenerator
  module Logging
    DEFAULT_LOG_PATH = File.expand_path("~/log")
    
    def to_yaml
      # Remove the leading triple-hyphen that separates docs: want it to be all one document
      # Bound it with a leading hyphen so the YAML dump interprets it as an element of a sequence
      "- #{to_hash.to_yaml.indent(2, " ", true)[8..-1]}"
    end

    def log(event)
      FileUtils.mkdir_p(log_path)
      @logfile ||= "#{log_path}/activity_generator_#{::Process.pid}.log"
      open(@logfile, "a") do |f|
        f << event.to_yaml
        f << "\n"
      end
    end

    def log_path
      ActivityGenerator::Runner.log_path || DEFAULT_LOG_PATH
    end
  end
end
