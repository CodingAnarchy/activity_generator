require 'socket'

module ActivityGenerator
  class NetworkActivity
    include Logging
    include ProcessHandler
    attr_reader :protocol, :remote_address, :transmit_file, :download_file

    def initialize(remote_addr: nil, transmit_filepath: nil, download_filename: nil)
      @transmit_file = transmit_filepath.present? ? File.expand_path(transmit_filepath) : nil
      @download_file = download_filename
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
      transmit_file.present? and not download_file.present?
    end

    def missing_login?
      !(remote_address =~ /\w+:\w+@/)
    end

    def run
      cmd = ['curl', '-v', '--local-port', local_port.to_s]
      case protocol
      when /http/
        cmd += ['-d', transmit_file] if upload?
        @process = Process.new(*cmd, remote_address, record_output: true)
      when /ftp/
        if missing_login?
          puts "Can't use FTP without login credentials."
          return
        end

        ftp_address = "#{remote_address}#{"/#{download_file}" unless upload?}"
        @process = Process.new(*cmd, ftp_address, upload? ? '-T' : '-o', transmit_file, '--ftp-port', '-', record_output: true)
        puts "FTP activity failed. FTP network configuration may not work on this system." unless $?.success?
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
      case protocol
      when "ftp" then 21 # FTP is served from port 21
      else
        @process.output[/port (\d+)/, 1]
      end
    end

    def data_transmitted
      return File.size?(transmit_file) if transmit_file.present? # Uploaded file or file downloaded to local location
      @process.output[/content-length: (\d+)/i, 1]
    end
  end
end
