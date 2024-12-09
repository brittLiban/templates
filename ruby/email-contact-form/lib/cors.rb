require 'dotenv'

class Cors
  def self.origin_permitted?(headers)
    return true if ENV['ALLOWED_ORIGINS'].nil? || 
                  ENV['ALLOWED_ORIGINS'] == '*' || 
                  headers['origin'].nil?
                  
    allowed_origins = ENV['ALLOWED_ORIGINS'].split(',')
    allowed_origins.include?(headers['origin'])
  end

  def self.cors_headers(headers)
    return {} if headers['origin'].nil?
    
    origin = if ENV['ALLOWED_ORIGINS'].nil? || ENV['ALLOWED_ORIGINS'] == '*'
      '*'
    else
      headers['origin']
    end
    
    { 'Access-Control-Allow-Origin' => origin }
  end
end