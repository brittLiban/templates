class Cors
    def origin_permitted?(request)
      return true if allowed_origins_open? || !request.headers['origin']
      allowed_origins_array.include?(request.headers['origin'])
    end
  
    def cors_headers(request)
      {
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers' => 'Content-Type'
      }
    end
  
    private
  
    def allowed_origins_open?
      ENV['ALLOWED_ORIGINS'].nil? || ENV['ALLOWED_ORIGINS'] == '*'
    end
  
    def allowed_origins_array
      ENV['ALLOWED_ORIGINS'].to_s.split(',')
    end
  end