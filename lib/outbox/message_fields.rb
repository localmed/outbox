module Outbox
  module MessageFields
    def self.included(base)
      base.extend Outbox::DefineInheritableMethod
      base.extend ClassMethods
    end

    module ClassMethods
      DYNAMIC_MODULE_NAME = :DynamicFields

      # Sets default values for defined fields.
      #
      #   Email.defaults from: 'bob@example.com'
      #   message = Email.new
      #   message.from #=> 'bob@example.com'
      def defaults(defaults = nil)
        @defaults ||= {}
        @defaults.merge!(defaults) if defaults
        @defaults
      end
      alias_method :defaults=, :defaults

      # Returns the defined fields for this message type.
      #
      #   class SomeMessageType < Outbox::Messages::Base
      #     field :to
      #     field :from
      #   end
      #
      #   SomeMessageType.fields #=> [:to, :from]
      #
      # Also allows you to define multiple fields at once.
      #
      #   class SomeMessageType < Outbox::Messages::Base
      #     fields :to, :from, required: true
      #   end
      #
      #   message = SomeMessageType.new do
      #     to 'Bob'
      #     from 'John'
      #   end
      #   message.to #=> 'Bob'
      #   message.from #=> 'John'
      #   message.from = nil
      #   message.validate_fields #=> raises Outbox::MissingRequiredFieldError
      def fields(*names)
        if names.empty?
          @fields ||= []
        else
          options = names.last.is_a?(Hash) ? names.pop : {}
          names.flatten.each do |name|
            field(name, options)
          end
        end
      end

      # Defines a 'field' which is a point of data for this type of data.
      # Optionally you can set it to be required, or wether or not you want
      # accessors defined for you. If you define your own accessors, make
      # sure the reader also accepts a value that can be set, so it'll work
      # with the block definition.
      #
      #   class SomeMessageType < Outbox::Messages::base
      #     field :to, required: true
      #     field :body, accessor: false
      #
      #     def body(value = nil)
      #       value ? self.body = value : @body
      #     end
      #
      #     def body=(value)
      #       @body = parse_body(value)
      #     end
      #   end
      #
      #   message = SomeMessageType.new do
      #     to 'Bob'
      #   end
      #   message.to #=> 'Bob'
      #   message.to = 'John'
      #   message.to #=> 'John'
      #   message.to = nil
      #   message.validate_fields #=> raises Outbox::MissingRequiredFieldError
      def field(name, options = {})
        name = name.to_sym
        options = Outbox::Accessor.new(options)

        fields.push(name)
        required_fields.push(name) if options[:required]

        unless options[:accessor] == false
          define_field_reader(name) unless options[:reader] == false
          define_field_writer(name) unless options[:writer] == false
        end
      end

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
          options = names.last.is_a?(Hash) ? names.pop : {}
          options[:required] = true
          names << options
          fields(*names)
        end
      end
      alias_method :required_field, :required_fields

      protected

      def define_field_reader(name)
        define_inheritable_method(DYNAMIC_MODULE_NAME, name) do |value = nil|
          if value.nil?
            @fields[name]
          else
            @fields[name] = value
          end
        end
      end

      def define_field_writer(name)
        define_inheritable_method(DYNAMIC_MODULE_NAME, "#{name}=") do |value|
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
        fields = {}
        self.class.fields.each do |field|
          fields[field] = public_send(field)
        end
        fields
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
        public_send(field, value) if respond_to?(field)
      end
    end

    # Checks the current values of the fields and raises errors for any
    # validation issues.
    def validate_fields
      self.class.required_fields.each do |field|
        value = public_send(field)
        if value.nil? || value.respond_to?(:empty?) && value.empty?
          raise Outbox::MissingRequiredFieldError, "Missing required field: #{field}"
        end
      end
    end
  end
end
