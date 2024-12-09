require 'json'
require_relative 'handlers/email_handler'
require_relative 'models/appwrite_request'
require_relative 'utils/response'

def main(context)
  request = AppwriteRequest.new(context)
  handler = EmailHandler.new(request)
  
  begin
    case request.method
    when 'GET'
      handler.handle_get
    when 'POST'
      handler.handle_post
    when 'OPTIONS'
      handler.handle_options
    else
      Response.error('Method not allowed', 405)
    end
  rescue => e
    puts "Error: #{e.message}"
    puts e.backtrace
    Response.error(e.message, 500)
  end
end