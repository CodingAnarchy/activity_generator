require 'socket'

module ActivityGenerator
  class NetworkActivity
    include Logging
    include ProcessHandler
    attr_reader :protocol, :remote_address, :transmit_file

    def initialize(remote_addr: nil, transmit_filepath: nil)
      @transmit_file = transmit_filepath.present? && File.expand_path(transmit_filepath)
      @remote_address = remote_addr || default_remote_addr
      @protocol = remote_address[/^(\w+):/, 1]
      run
    end

    def to_hash
      {
        network: {
          destination_address: upload? ? remote_address : PUBLIC_IP,
          destination_port: (upload? ? remote_port : local_port).to_i,
          source_address: upload? ? PUBLIC_IP : remote_address,
          source_port: (upload? ? local_port : remote_port).to_i,
          protocol: protocol,
          amount_transmitted: data_transmitted.to_i
        }.merge(process_hash)
      }
    end

    private

    def upload?
      transmit_file.present?
    end

    def run
      cmd = ['curl', '-v', '--local-port', local_port.to_s]
      if upload?
        @process = Process.new(*cmd, '-d', "#{@transmit_file}", "#{remote_address}", record_output: true)
      else
        @process = Process.new(*cmd, "#{remote_address}", record_output: true)
      end
      log(self)
    end

    def default_remote_addr
      upload? ? 'http://devnull-as-a-service.com/dev/null' : 'https://curl.haxx.se'
    end

    def local_port
      @local_port ||= Addrinfo.tcp("", 0).bind{|s| s.local_address.ip_port}
    end

    def remote_port
      @process.output[/port (\d+)/, 1]
    end

    def data_transmitted
      upload? ? File.size?(@transmit_file) : @process.output[/content-length: (\d+)/i, 1]
    end
  end
end
