require 'ipaddr'
require 'open-uri'

class IPAddr
  # Allows us to output a CIDR string of an IPAddr object
  def to_cidr
    "#{self}/#{@mask_addr.to_s(2).count('1')}" if @addr && @mask_addr
  end

  # Get the current public IP
  # IPv4 only
  class << self
    def current_public_ip
      %w[http://ipv4.icanhazip.com http://ipecho.net/plain].each do |endpoint|
        begin
          return IPAddr.new(open(endpoint, read_timeout: 3).read.strip)
        rescue Net::ReadTimeout
          next
        end
      end
    end
  end
end
