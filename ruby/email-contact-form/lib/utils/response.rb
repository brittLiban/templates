require 'json'
require_relative 'cors'

class Response
  def self.success(body, content_type = 'application/json', status_code = 200)
    {
      statusCode: status_code,
      headers: {
        'Content-Type' => content_type
      }.merge(Cors.new.cors_headers(nil)),
      body: body
    }
  end

  def self.error(message, status_code = 400)
    {
      statusCode: status_code,
      headers: {
        'Content-Type' => 'application/json'
      }.merge(Cors.new.cors_headers(nil)),
      body: JSON.generate({ error: message })
    }
  end

  def self.redirect(url, status_code = 302)
    {
      statusCode: status_code,
      headers: {
        'Location' => url
      }.merge(Cors.new.cors_headers(nil)),
      body: ''
    }
  end
end