module Outbox
  module Messages
    class Base
      include MessageClients
      include MessageFields

      # Make a new message. Every message type can be created using a hash,
      # block, or direct assignment.
      #
      #   message = Email.new(
      #     to: 'someone@example.com',
      #     from: 'company@example.com'
      #   )
      #   message = Email.new do
      #     to 'someone@example.com'
      #     from 'company@example.com'
      #   end
      #   message = Email.new
      #   message.to = 'someone@example.com'
      #   message.from = 'company@example.com'
      def initialize(fields = nil, &block)
        @fields = {}
        if self.class.default_client
          @client = self.class.default_client.dup
        else
          @client = nil
        end

        self.fields = self.class.defaults

        if block_given?
          instance_eval(&block)
        else
          self.fields = fields unless fields.nil?
        end
      end

      # Sets the 'audience' for this message. All message types must implement
      # this method. By default, this is an alias for a 'to' field if present.
      def audience=(audience)
        self.to = audience if self.respond_to?(:to=)
      end

      # Sets the 'body' for this message. All message types must implement
      # this method.
      def body=(body)
        raise NotImplementedError, 'Subclasses must implement a body= method'
      end

      # Validates the current message and delivers the message using the
      # defined client.
      def deliver(audience = nil)
        self.audience = audience if audience
        validate_fields
        client.deliver(self)
      end
    end
  end
end
