module Outbox
  module MessageFields
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Sets default values for defined fields.
      #
      #   Email.defaults from: 'bob@example.com'
      #   message = Email.new
      #   message.from #=> 'bob@example.com'
      def defaults(defaults = nil)
        @defaults ||= {}

        if defaults.nil?
          @defaults
        else
          @defaults.merge!(defaults)
        end
      end

      # Defines a field or fields which will become accessors and used by the
      # defined client to deliver the message. Optionally, you can set certain
      # fields to be required.
      #
      #   class SomeMessageType < Outbox::Messages::Base
      #     fields :to, :from, required: true
      #   end
      #   message = SomeMessageType.new
      #   message.to = 'Bob'
      #   message.to #=> 'Bob'
      #   message.from 'John'
      #   message.from #=> 'John'
      #   message.from = nil
      #   message.validate_fields #=> raises Outbox::MissingRequiredFieldError
      def fields(*names)
        options = names.last.is_a?(Hash) ? names.pop : {}
        required_fields.push(*names) if options[:required]
        names.flatten.each do |name|
          name = name.to_sym
          define_field_reader(name)
          define_field_writer(name)
        end
      end
      alias :field :fields

      # Returns an array of the required fields for a message type.
      #
      #   class SomeMessageType < Outbox::Messages::Base
      #     field :to, required: true
      #     fields :from, :subject
      #   end
      #   SomeMessageType.required_fields #=> [:to]
      #
      # Also can be used an alias for defining fields that are required.
      #
      #   class SomeMessageType < Outbox::Messages::Base
      #     required_fields :to, :from
      #   end
      #   SomeMessageType.required_fields #=> [:to, :from]
      def required_fields(*names)
        if names.empty?
          @required_fields ||= []
        else
          names << { required: true }
          fields(*names)
        end
      end
      alias :required_field :required_fields

      protected

      def define_field_reader(name)
        define_method(name) do |value = nil|
          if value.nil?
            @fields[name]
          else
            @fields[name] = value
          end
        end
      end

      def define_field_writer(name)
        define_method("#{name}=") do |value|
          @fields[name] = value
        end
      end
    end

    # Read an arbitrary field.
    #
    # Example:
    #
    #  message['foo'] = '1234'
    #  message['foo'] #=> '1234'
    def [](name)
      @fields[name.to_sym]
    end

    # Add an arbitray field.
    #
    # Example:
    #
    #  message['foo'] = '1234'
    #  message['foo'] #=> '1234'
    def []=(name, value)
      @fields[name.to_sym] = value
    end

    # Returns a hash of the defined fields.
    #
    #   class SomeMessageType < Outbox::Messages::Base
    #     fields :to, :from
    #   end
    #   message = SomeMessageType.new to: 'Bob'
    #   message.from 'John'
    #   message.fields #=> { to: 'Bob', from: 'John' }
    #
    # Also allows you to set fields if you pass in a hash.
    #
    #   message.fields to: 'Bob', from: 'Sally'
    #   message.fields #=> { to: 'Bob', from: 'Sally' }
    def fields(new_fields = nil)
      if new_fields.nil?
        @fields.dup
      else
        self.fields = new_fields
      end
    end

    # Assigns the values of the given hash.
    #
    #   message.to = 'Bob'
    #   message.fields = { from: 'Sally' }
    #   message.fields #=> { to: 'Bob', from: 'Sally' }
    def fields=(new_fields)
      new_fields.each do |field, value|
        self.public_send(field, value) if self.respond_to?(field)
      end
    end

    # Checks the current values of the fields and raises errors for any
    # validation issues.
    def validate_fields
      self.class.required_fields.each do |field|
        value = self.public_send(field)
        if value.nil? || value.respond_to?(:empty?) && value.empty?
          raise Outbox::MissingRequiredFieldError.new("Missing required field: #{field}")
        end
      end
    end
  end
end
