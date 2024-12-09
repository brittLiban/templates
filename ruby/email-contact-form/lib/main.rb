require 'json'
require_relative 'email_handler'
require_relative 'response'

def main(context)
  begin
    request = context.req
    handler = EmailHandler.new(request)
    
    case request.method
    when 'GET'
      handler.handle_get
    when 'POST'
      handler.handle_post
    else
      Response.error('Method not allowed', 405)
    end
  rescue => e
    Response.error(e.message, 500)
  end
end