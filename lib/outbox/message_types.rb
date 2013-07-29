module Outbox
  module MessageTypes
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Registers a message type for sending & creates accessors.
      #
      #   Message.register_message_type :telepathy, TelepathyMessage
      #   message = Message.new do
      #     telepathy do
      #       thought 'Hello world.'
      #     end
      #   end
      #   message.telepathy.thought #=> 'Hello world.'
      #
      # Upon deliver the audience object will be checked for the registered
      # message type.
      #
      #   message.deliver telepathy: 'Bob'
      def register_message_type(name, message_type)
        message_types[name.to_sym] = message_type
        define_message_type_reader(name, message_type)
        define_message_type_writer(name)
      end

      # Returns a hash of the registred message types, where the key is the name
      # of the message type and the value is the message type class.
      def message_types
        @message_types ||= {}
      end

      protected

      def define_message_type_reader(name, message_type)
        ivar_name = "@#{name}"
        define_method(name) do |options = nil, &block|
          if options || block
            instance_variable_set(ivar_name, message_type.new(options, &block))
          else
            instance_variable_get(ivar_name)
          end
        end
      end

      def define_message_type_writer(name)
        define_method("#{name}=") do |value|
          instance_variable_set("@#{name}", value)
        end
      end
    end

    protected

    def assign_message_type_values(values)
      values.each do |key, value|
        self.public_send(key, value) if self.respond_to?(key)
      end
    end
  end
end
