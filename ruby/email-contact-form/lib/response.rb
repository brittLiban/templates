class Response
    def self.success(body, content_type = 'application/json')
      {
        statusCode: 200,
        headers: {
          'Content-Type' => content_type
        },
        body: body
      }
    end
  
    def self.error(message, status_code = 400)
      {
        statusCode: status_code,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: JSON.generate({ error: message })
      }
    end
  
    def self.redirect(url, status_code = 302)
      {
        statusCode: status_code,
        headers: {
          'Location' => url
        },
        body: ''
      }
    end
  end