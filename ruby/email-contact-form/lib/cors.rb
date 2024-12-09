require 'dotenv'

def origin_permitted?(req)
  return true if ENV['ALLOWED_ORIGINS'].nil? || 
                 ENV['ALLOWED_ORIGINS'] == '*' || 
                 req.headers['origin'].nil?
                 
  allowed_origins = ENV['ALLOWED_ORIGINS'].split(',')
  allowed_origins.include?(req.headers['origin'])
end

def cors_headers(req)
  return {} if req.headers['origin'].nil?
  
  origin = if ENV['ALLOWED_ORIGINS'].nil? || ENV['ALLOWED_ORIGINS'] == '*'
    '*'
  else
    req.headers['origin']
  end
  
  { 'Access-Control-Allow-Origin' => origin }
end