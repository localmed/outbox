module Outbox
  module Clients
    class MailClient < Base
      defaults delivery_method: :smtp

      # Returns the configured delivery method.
      def delivery_method
        settings[:delivery_method]
      end

      # Returns the configured delivery method settings. This will also check
      # the Rails-style #{delivery_method}_settings key as well.
      #
      #   client = Outbox::Clients::MailClient.new(
      #     delivery_method: :sendmail,
      #     delivery_method_settings: { location: '/usr/bin/sendmail' }
      #   )
      #   client.delivery_method_settings #=> { location: '/usr/bin/sendmail' }
      #
      #   client = Outbox::Clients::MailClient.new(
      #     delivery_method: :sendmail,
      #     sendmail_settings: { location: '/usr/bin/sendmail' }
      #   )
      #   client.delivery_method_settings #=> { location: '/usr/bin/sendmail' }
      def delivery_method_settings
        (
          settings[:delivery_method_settings] ||
          settings[:"#{delivery_method}_settings"] ||
          {}
        )
      end

      def deliver(email)
        message = create_message_from_email(email)
        message.delivery_method(delivery_method, delivery_method_settings)
        message.deliver
      end

      private

      def create_message_from_email(email)
        email.message_object.dup
      end
    end
  end
end
