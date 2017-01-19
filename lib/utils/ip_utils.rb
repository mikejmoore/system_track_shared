def padded_ip(ip_address)
  parts = ip_address.split(".")
  new_parts = []
  parts.each do |part|
    while(part.length < 3)
      part = "0" + part 
    end
    new_parts << part
  end
  return new_parts.join(".")
end
