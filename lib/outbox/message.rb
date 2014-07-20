module Outbox
  class Message
    include MessageTypes

    register_message_type :email, Outbox::Messages::Email
    register_message_type :sms, Outbox::Messages::SMS

    # Use the Outbox::Clients::TestClient for all message types. This is
    # useful for testing or working an a development environment.
    def self.use_test_client
      message_types.each_value do |message_type|
        message_type.default_client(:test)
      end
    end

    # Make a new message. Every message can be created using a hash,
    # block, or direct assignment.
    #
    #   message = Message.new do
    #     email do
    #       subject 'Subject'
    #     end
    #   end
    #   message = Message.new email: { subject: 'Subject' }
    #   message = Message.new
    #   message.email = Email.new subject: 'Subject'
    def initialize(message_type_values = nil, &block)
      if block_given?
        instance_eval(&block)
      elsif message_type_values
        assign_message_type_values(message_type_values)
      end
    end

    # Loops through each registered message type and sets the content body.
    def body(value)
      each_message_type do |_, message|
        next if message.nil?
        message.body = value
      end
    end
    alias_method :body=, :body

    # Delivers all of the messages to the given 'audience'. An 'audience'
    # object can be a hash or an object that responds to the current message
    # types. Only the message types specified in the 'audience' object will
    # be sent to.
    #
    #   message.deliver email: 'hello@example.com', sms: '+15555555555'
    #   audience = OpenStruct.new
    #   audience.email = 'hello@example.com'
    #   audience.sms = '+15555555555'
    #   message.deliver(audience)
    def deliver(audience)
      audience = Outbox::Accessor.new(audience)

      each_message_type do |message_type, message|
        next if message.nil?

        recipient = audience[message_type]
        message.deliver(recipient) if recipient
      end
    end
  end
end
