require 'uri'

module Utils
  def self.throw_if_missing(obj, keys)
    missing = keys.select { |key| !obj.key?(key) || obj[key].nil? }
    raise "Missing required fields: #{missing.join(', ')}" unless missing.empty?
  end

  def self.get_static_file(file_name)
    File.read(File.join(__dir__, '../static', file_name))
  end

  def self.url_with_code_param(base_url, code_param)
    uri = URI(base_url)
    params = URI.decode_www_form(uri.query || '') << ['code', code_param]
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end
end