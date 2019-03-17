require 'socket'

module ActivityGenerator
  class NetworkActivity
    include Logging
    include ProcessHandler
    attr_reader :upload, :remote_addr, :remote_port, :local_addr

    def initialize(upload: true, remote_addr: nil, remote_port: nil, transmit_filepath: nil)
      @upload = upload
      @remote_addr = remote_addr || default_remote_addr
      @remote_port = remote_port || (@remote_addr =~ /https/ ? '443' : '80')
      @transmit_file = transmit_filepath.present? ? File.expand_path(transmit_filepath) : TEST_FILE
      run
    end

    def to_hash
      {
        network: {
          destination_address: upload ? remote_addr : PUBLIC_IP,
          destination_port: (upload ? remote_port : local_port).to_i,
          source_address: upload ? PUBLIC_IP : remote_addr,
          source_port: (upload ? local_port : remote_port).to_i,
          protocol: protocol,
          amount_transmitted: data_transmitted.to_i
        }.merge(process_hash)
      }
    end

    private

    def run
      cmd = ['curl', '-i', '--local-port', local_port.to_s]
      if upload
        @process = Process.new(*cmd, '-d', "#{@transmit_file}", '-X', 'POST', "#{remote_addr}:#{remote_port}", record_output: true)
      else
        @process = Process.new(*cmd, "#{remote_addr}:#{remote_port}", record_output: true)
      end
      log(self)
    end

    def default_remote_addr
      upload ? 'http://devnull-as-a-service.com/dev/null' : 'https://curl.haxx.se'
    end

    def local_port
      @local_port ||= Addrinfo.tcp("", 0).bind{|s| s.local_address.ip_port}
    end

    def protocol
      @process.output.split(' ')[0] # First part of curl -i header line, e.g.: HTTP/1.1
    end

    def data_transmitted
      upload ? File.size?(@transmit_file) : @process.output[/content-length: (\d+)/, 1]
    end
  end
end
