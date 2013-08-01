module Outbox
  module MessageTypes
    def self.included(base)
      base.extend Outbox::DefineInheritableMethod
      base.extend ClassMethods
    end

    module ClassMethods
      DYNAMIC_MODULE_NAME = :DynamicMessageTypes

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
        define_default_message_type_client_accessors(name, message_type)
        define_default_message_type_client_settings_accessors(name, message_type)
        define_message_type_defaults_accessors(name, message_type)
      end

      # Returns a hash of the registred message types, where the key is the name
      # of the message type and the value is the message type class.
      def message_types
        @message_types ||= {}
      end

      protected

      def define_message_type_reader(name, message_type)
        ivar_name = "@#{name}"
        define_inheritable_method(DYNAMIC_MODULE_NAME, name) do |fields = nil, &block|
          instance = instance_variable_get(ivar_name)

          if instance.nil? && (fields || block)
            instance = message_type.new
            instance_variable_set(ivar_name, instance)
          end

          if block
            instance.instance_eval(&block)
          elsif fields
            instance.fields = fields
          end

          instance
        end
      end

      def define_message_type_writer(name)
        define_inheritable_method(DYNAMIC_MODULE_NAME, "#{name}=") do |value|
          instance_variable_set("@#{name}", value)
        end
      end

      def define_default_message_type_client_accessors(name, message_type)
        define_singleton_method "default_#{name}_client" do |*args|
          message_type.default_client(*args)
        end

        define_singleton_method "default_#{name}_client=" do |client|
          message_type.default_client = client
        end
      end

      def define_default_message_type_client_settings_accessors(name, message_type)
        define_singleton_method "default_#{name}_client_settings" do |*args|
          message_type.default_client_settings(*args)
        end

        define_singleton_method "default_#{name}_client_settings=" do |settings|
          message_type.default_client_settings = settings
        end
      end

      def define_message_type_defaults_accessors(name, message_type)
        define_singleton_method "#{name}_defaults" do |*args|
          message_type.defaults(*args)
        end

        define_singleton_method "#{name}_defaults=" do |defaults|
          message_type.defaults = defaults
        end
      end
    end

    # Assign the given hash where each key is a message type and
    # the value is a hash of options for that message type.
    def assign_message_type_values(values)
      values.each do |key, value|
        self.public_send(key, value) if self.respond_to?(key)
      end
    end

    # Loops through each registered message type and yields the instance
    # of that type on this message.
    def each_message_type
      self.class.message_types.each_key do |message_type|
        yield message_type, self.public_send(message_type)
      end
    end
  end
end
