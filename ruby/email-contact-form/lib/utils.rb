require 'mail'
require 'uri'

class Utils
  def send_email(options)
    Mail.defaults do
      delivery_method :smtp, {
        address: ENV['SMTP_HOST'],
        port: ENV['SMTP_PORT'] || 587,
        user_name: ENV['SMTP_USERNAME'],
        password: ENV['SMTP_PASSWORD']
      }
    end

    Mail.new do
      to options[:to]
      from options[:from]
      subject options[:subject]
      body options[:body]
    end.deliver!
  end

  def template_form_message(form_data)
    message_parts = form_data
      .reject { |key, _| key == '_next' }
      .map { |key, value| "#{key}: #{value}" }
    
    "You've received a new message.\n\n#{message_parts.join("\n")}"
  end

  def url_with_code_param(base_url, code_param)
    uri = URI.parse(base_url)
    params = URI.decode_www_form(uri.query || '').to_h
    params['code'] = code_param
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  def get_static_file(filename)
    File.read(File.join(__dir__, 'static', filename))
  end
end