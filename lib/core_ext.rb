class IPAddr
  # Allows us to output a CIDR string of an IPAddr object
  def to_cidr_s
    if @addr
      mask = @mask_addr.to_s(2).count('1')
      "#{to_s}/#{mask}"
    else
      nil
    end
  end
end
