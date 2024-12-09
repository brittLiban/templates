require 'dotenv'
require 'mail'
require 'uri'

class Utils
  def self.throw_if_missing(obj, keys)
    missing = keys.select { |key| !obj.key?(key) || obj[key].nil? }
    raise "Missing required fields: #{missing.join(', ')}" unless missing.empty?
  end

  def self.get_static_file(file_name)
    File.read(File.join(__dir__, '../static', file_name))
  end

  def self.template_form_message(form)
    message = "You've received a new message.\n\n"
    form_entries = form.reject { |key, _| key == '_next' }
                      .map { |key, value| "#{key}: #{value}" }
                      .join("\n")
    message + form_entries
  end

  def self.url_with_code_param(base_url, code_param)
    uri = URI(base_url)
    params = URI.decode_www_form(uri.query || '') << ['code', code_param]
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  def self.send_email(options)
    Mail.defaults do
      delivery_method :smtp, {
        address: ENV['SMTP_HOST'],
        port: ENV['SMTP_PORT'] || 587,
        user_name: ENV['SMTP_USERNAME'],
        password: ENV['SMTP_PASSWORD']
      }
    end

    Mail.new do
      from options[:from]
      to options[:to]
      subject options[:subject]
      body options[:body]
    end.deliver!
  end
end