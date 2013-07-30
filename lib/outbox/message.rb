module Outbox
  class Message
    include MessageTypes

    register_message_type :email, Outbox::Messages::Email

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
      else
        assign_message_type_values(message_type_values) unless message_type_values.nil?
      end
    end

    # Delivers all of the messages to the given 'audience'. An 'audience' object
    # can be a hash or an object that responds to the current message types. Only
    # the message types specified in the 'audience' object will be sent to.
    #
    #   message.deliver email: 'hello@example.com', sms: '+15555555555'
    #   audience = OpenStruct.new
    #   audience.email = 'hello@example.com'
    #   audience.sms = '+15555555555'
    #   message.deliver(audience)
    def deliver(audience)
      audience = Outbox::Accessor.new(audience)

      self.class.message_types.each_key do |message_type|
        message = self.public_send(message_type)
        next if message.nil?

        recipient = audience[message_type]
        message.deliver(recipient) if recipient
      end
    end
  end
end
