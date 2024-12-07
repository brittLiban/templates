require 'dotenv'
require 'pathname'
require 'fileutils'
require 'net/smtp'
require 'mail'
require 'uri'

def throw_if_missing(obj, keys)
  missing = keys.select { |key| !obj.key?(key) || obj[key].nil? || obj[key].empty? }
  raise "Missing required fields: #{missing.join(', ')}" unless missing.empty?
end

def get_static_file(file_name)
  static_folder = File.expand_path('../static', __FILE__)
  file_path = File.join(static_folder, file_name)
  File.read(file_path)
end

def template_form_message(form)
  "You've received a new message.\n\n" +
    form.reject { |key, _| key == '_next' }
        .map { |key, value| "#{key}: #{value}" }
        .join("\n")
end

def url_with_code_param(base_url, code_param)
  uri = URI(base_url)
  params = URI.decode_www_form(uri.query || '') << ['code', code_param]
  uri.query = URI.encode_www_form(params)
  uri.to_s
end

def send_email(options)
  mail = Mail.new do
    from    options[:from]
    to      options[:to]
    subject options[:subject]
    body    options[:text]
  end

  mail.delivery_method :smtp, {
    address: ENV['SMTP_HOST'],
    port: ENV['SMTP_PORT'] || 587,
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    authentication: 'plain',
    enable_starttls_auto: true
  }

  mail.deliver!
end