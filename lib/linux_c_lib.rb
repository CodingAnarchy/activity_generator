require 'ffi'

module LinuxCLib
  extend FFI::Library
  ffi_lib 'c'

  @@cg = FFI::ConstGenerator.new(nil, required: true) do |gen|
    gen.include('unistd.h')
    gen.const(:_SC_CLK_TCK)
  end

  attach_function :sysconf, [:int], :long

  def self.hz
    self.sysconf(@@cg["_SC_CLK_TCK"].to_i)
  end
end
