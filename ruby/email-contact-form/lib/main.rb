require_relative 'utils'
require_relative 'cors'
require 'dotenv'
require 'json'

class EmailContact
  def self.handle_request(method, headers, params)
    case method
    when 'GET'
      handle_get(headers)
    when 'POST'
      handle_post(headers, params)
    else
      { status: 405, headers: {}, body: 'Method not allowed' }
    end
  end

  private

  def self.handle_get(headers)
    return { status: 403, body: 'Forbidden' } unless Cors.origin_permitted?(headers)

    {
      status: 200,
      headers: Cors.cors_headers(headers).merge('Content-Type' => 'text/html'),
      body: Utils.get_static_file('index.html')
    }
  end

  def self.handle_post(headers, params)
    return { status: 403, body: 'Forbidden' } unless Cors.origin_permitted?(headers)

    begin
      Utils.throw_if_missing(params, ['_next'])
      
      Utils.send_email(
        from: ENV['SMTP_USERNAME'],
        to: ENV['SUBMIT_EMAIL'],
        subject: 'New Contact Form Submission',
        body: Utils.template_form_message(params)
      )

      {
        status: 302,
        headers: Cors.cors_headers(headers).merge('Location' => params['_next']),
        body: ''
      }
    rescue => e
      next_url = Utils.url_with_code_param(params['_next'], e.message)
      {
        status: 302,
        headers: Cors.cors_headers(headers).merge('Location' => next_url),
        body: ''
      }
    end
  end
end