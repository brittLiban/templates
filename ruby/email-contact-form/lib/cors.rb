require 'dotenv/load'

def is_origin_permitted(request)
  allowed_origins = ENV['ALLOWED_ORIGINS']
  origin = request.header['origin']&.first

  return true if allowed_origins.nil? || allowed_origins == '*' || origin.nil?

  allowed_origins_array = allowed_origins.split(',')
  allowed_origins_array.include?(origin)
end

def get_cors_headers(request)
  origin = request.header['origin']&.first
  return {} if origin.nil?

  allowed_origins = ENV['ALLOWED_ORIGINS']
  {
    'Access-Control-Allow-Origin' => 
      allowed_origins.nil? || allowed_origins == '*' ? '*' : origin
  }
end