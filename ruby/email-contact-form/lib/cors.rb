require 'dotenv/load'

def is_origin_permitted(req)
  allowed_origins = ENV['ALLOWED_ORIGINS']
  origin = req[:headers]['origin']

  return true if allowed_origins.nil? || allowed_origins == '*' || origin.nil?

  allowed_origins_array = allowed_origins.split(',')
  allowed_origins_array.include?(origin)
end

def get_cors_headers(req)
  origin = req[:headers]['origin']
  return {} if origin.nil?

  allowed_origins = ENV['ALLOWED_ORIGINS']
  {
    'Access-Control-Allow-Origin' => 
      allowed_origins.nil? || allowed_origins == '*' ? '*' : origin
  }
end