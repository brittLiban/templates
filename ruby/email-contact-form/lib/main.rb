require_relative 'request_handler'
require 'dotenv/load'
require 'json'

def main(context)
  req = context.req
  method = req.method
  headers = req.headers
  
  # Parse request parameters based on method and content type
  params = if method == 'POST'
    if headers['content-type']&.include?('application/json')
      JSON.parse(req.body_raw || '{}')
    else
      # Parse form data
      body = req.body_raw || ''
      URI.decode_www_form(body).to_h
    end
  else
    req.query
  end

  response = RequestHandler.handle(method, headers, params)
  
  context.response.status = response[:status]
  response[:headers]&.each do |key, value|
    context.response.header(key, value)
  end
  context.response.send(response[:body])
end