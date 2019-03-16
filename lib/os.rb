module OS
  class << self
    def windows?
      !!(/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM)
    end

    def mac?
      !!(/darwin/ =~ RUBY_PLATFORM)
    end

    def unix?
      !windows?
    end

    def linux?
      unix? and not mac?
    end
  end
end
