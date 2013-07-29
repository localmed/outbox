module Outbox
  module Messages
    class Base
      include MessageClients
      include MessageFields

      # Make a new message. Every message type can be created using a hash,
      # block, or direct assignment.
      #
      #   message = Email.new to: 'someone@example.com', from: 'company@example.com'
      #   message = Email.new do
      #     to 'someone@example.com'
      #     from 'company@example.com'
      #   end
      #   message = Email.new
      #   message.to = 'someone@example.com'
      #   message.from = 'company@example.com'
      def initialize(fields = nil, &block)
        @fields = self.class.defaults.dup
        @client = self.class.default_client and self.class.default_client.dup

        if block_given?
          instance_eval(&block)
        else
          self.fields = fields unless fields.nil?
        end
      end

      # Validates the current message and delivers the message using the
      # defined client.
      def deliver
        validate_fields
        client.deliver(self)
      end
    end
  end
end
