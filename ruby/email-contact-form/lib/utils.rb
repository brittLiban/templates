require 'dotenv/load'
require 'pathname'
require 'fileutils'
require 'net/smtp'
require 'mail'

# Helper methods for utilities

# Throws an error if any of the keys are missing from the object
# @param [Hash] obj The object to check
# @param [Array<String>] keys The keys to validate
# @raises [RuntimeError] If any keys are missing
def throw_if_missing(obj, keys)
  missing = keys.select { |key| !obj.key?(key) || obj[key].nil? || obj[key].empty? }
  raise "Missing required fields: #{missing.join(', ')}" unless missing.empty?
end

# Returns the contents of a file in the static folder
# @param [String] file_name The name of the file
# @returns [String] Contents of static/{file_name}
def get_static_file(file_name)
  static_folder = File.expand_path('../static', __dir__)
  file_path = File.join(static_folder, file_name)
  File.read(file_path)
end

# Build a message from the form data.
# @param [Hash] form The parsed form data
# @returns [String] Formatted message string
def template_form_message(form)
  "You've received a new message.\n\n" +
    form.reject { |key, _| key == '_next' }
        .map { |key, value| "#{key}: #{value}" }
        .join("\n")
end

# Builds a URL with an additional code parameter
# @param [String] base_url The base URL
# @param [String] code_param The code to append
# @returns [String] The updated URL
def url_with_code_param(base_url, code_param)
  uri = URI(base_url)
  params = URI.decode_www_form(uri.query || '') << ['code', code_param]
  uri.query = URI.encode_www_form(params)
  uri.to_s
end

# Sends an email using the SMTP credentials from the environment
# @param [Hash] options The email options (to, from, subject, text)
# @returns [void]
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