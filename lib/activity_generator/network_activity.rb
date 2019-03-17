require 'socket'

module ActivityGenerator
  class NetworkActivity
    attr_reader :upload, :remote_addr, :remote_port, :local_addr, :process_data

    def initialize(upload: true, remote_addr: nil, remote_port: nil, transmit_filepath: nil)
      @upload = upload
      @remote_addr = remote_addr || default_remote_addr
      @remote_port = remote_port || (upload ? '80' : '443')
      @transmit_file = transmit_filepath.present? ? File.expand_path(transmit_filepath) : TEST_FILE
      run
    end

    def to_hash
      {
        network: {
          destination_address: upload ? remote_addr : public_ip,
          destination_port: upload ? remote_port : local_port,
          source_address: upload ? public_ip : remote_addr,
          source_port: upload ? local_port : remote_port,
        }.merge(process_hash)
      }
    end

    def to_yaml
      to_hash.to_yaml
    end

    private

    def run
      cmd = ['curl', '--local-port', local_port.to_s]
      if upload
        @process_data = ProcessData.new(Process.new(*cmd, '-d', "#{@transmit_file}", '-X', 'POST', "#{remote_addr}:#{remote_port}").data)
      else
        @process_data = ProcessData.new(Process.new(*cmd, "#{remote_addr}:#{remote_port}").data)
      end
    end

    def default_remote_addr
      upload ? 'http://devnull-as-a-service.com/dev/null' : 'https://curl.haxx.se'
    end

    def public_ip
      @local_addr ||= Socket.ip_address_list.detect{|intf| intf.ipv4? && !intf.ipv4_loopback? && !intf.ipv4_multicast? && !intf.ipv4_private?}&.ip_address
    end

    def local_port
      @local_port ||= Addrinfo.tcp("", 0).bind{|s| s.local_address.ip_port}
    end

    def process_hash
      @process_data.to_hash
    end
  end
end
