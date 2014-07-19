module HugoHelper
  
  BYTES_IN_KB = 10**3
  BYTES_IN_MB = 10**6
  BYTES_IN_GB = 10**9
  BYTES_IN_TB = 10**12
  
  def pretty_bytes_string(bytes)
    return "%.1f TB" % (bytes.to_f / BYTES_IN_TB) if bytes > BYTES_IN_TB
    return "%.1f GB" % (bytes.to_f / BYTES_IN_GB) if bytes > BYTES_IN_GB
    return "%.1f MB" % (bytes.to_f / BYTES_IN_MB) if bytes > BYTES_IN_MB
    return "%.1f KB" % (bytes.to_f / BYTES_IN_KB) if bytes > BYTES_IN_KB
    return "#{bytes} B"
  end
  
  def file_kind_descr(resitem)
    return "directory" if resitem["entity_type"] == "directory"
    return KindTab.find(resitem["kind_id"]).description
  end
  
  
end
