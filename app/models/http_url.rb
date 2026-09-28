module HttpUrl
  # Only http(s) with a host; rejects javascript:, data: and other schemes.
  def self.valid?(url)
    uri = URI.parse(url.to_s)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
