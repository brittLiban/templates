require 'mail'

module EmailHandler
  def self.send_contact_form(form_data)
    send_email(
      from: ENV['SMTP_USERNAME'],
      to: ENV['SUBMIT_EMAIL'],
      subject: 'New Contact Form Submission',
      body: template_form_message(form_data)
    )
  end

  private

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

  def self.template_form_message(form)
    message = "You've received a new message.\n\n"
    form_entries = form.reject { |key, _| key == '_next' }
                      .map { |key, value| "#{key}: #{value}" }
                      .join("\n")
    message + form_entries
  end
end