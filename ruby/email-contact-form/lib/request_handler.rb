require_relative 'email_handler'
require_relative 'response_builder'
require_relative 'utils'
require_relative 'cors'

module RequestHandler
  def self.handle(method, headers, params)
    case method
    when 'GET'
      handle_get(headers)
    when 'POST'
      handle_post(headers, params)
    else
      ResponseBuilder.error(405, 'Method not allowed')
    end
  end

  private

  def self.handle_get(headers)
    return ResponseBuilder.forbidden unless Cors.origin_permitted?(headers)

    ResponseBuilder.success_html(
      Utils.get_static_file('index.html'),
      Cors.cors_headers(headers)
    )
  end

  def self.handle_post(headers, params)
    return ResponseBuilder.forbidden unless Cors.origin_permitted?(headers)

    begin
      Utils.throw_if_missing(params, ['_next'])
      EmailHandler.send_contact_form(params)
      ResponseBuilder.redirect(params['_next'], Cors.cors_headers(headers))
    rescue => e
      next_url = Utils.url_with_code_param(params['_next'], e.message)
      ResponseBuilder.redirect(next_url, Cors.cors_headers(headers))
    end
  end
end