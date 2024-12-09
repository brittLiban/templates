module ResponseBuilder
    def self.success_html(body, headers = {})
      {
        status: 200,
        headers: headers.merge('Content-Type' => 'text/html'),
        body: body
      }
    end
  
    def self.redirect(url, headers = {})
      {
        status: 302,
        headers: headers.merge('Location' => url),
        body: ''
      }
    end
  
    def self.forbidden
      {
        status: 403,
        body: 'Forbidden'
      }
    end
  
    def self.error(status, message)
      {
        status: status,
        headers: {},
        body: message
      }
    end
  end