require_relative 'request_handler'
require 'dotenv/load'
require 'json'

def main(context)
  req = context.req
  method = req.method
  headers = req.headers
  params = req.payload || {}

  response = RequestHandler.handle(method, headers, params)
  
  context.response.status = response[:status]
  response[:headers]&.each do |key, value|
    context.response.header(key, value)
  end
  context.response.send(response[:body])
end