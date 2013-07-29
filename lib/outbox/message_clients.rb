module Outbox
  module MessageClients
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Returns the default client for the message type.
      #
      #   Email.default_client #=> #<Outbox::Clients::Mail>
      #
      # Also allows you to set the default client using an alias, with optoins.
      #
      #   Email.default_client :test, option: 'foo'
      #   Email.default_client #=> #<Outbox::Clients::TestClient>
      def default_client(client = nil, options = nil)
        if client.nil?
          @default_client
        else
          @default_client = get_client(client, options)
        end
      end

      # Registers a client class with an alias.
      #
      #   Email.register_client_alias :mandrill, MandrillClient
      #   Email.default_client :mandrill, mandrill_option: 'foo'
      def register_client_alias(name, client)
        registered_client_aliases[name.to_sym] = client
      end

      # Returns a hash of client aliases, where the key is the alias and
      # the value is client class.
      def registered_client_aliases
        @registered_client_aliases ||= { test: Outbox::Clients::TestClient }
      end

      protected

      def get_client(client, options = nil)
        case client
        when Symbol, String
          client = registered_client_aliases[client.to_sym]
        end

        if client.instance_of?(Class)
          client.new(options)
        else
          client
        end
      end
    end

    # Returns the message's client.
    #
    #   message.client #=> #<Outbox::Clients::Mail>
    #
    # Also allows you set the instance's client using an alias, with options.
    #
    #   message.client :test, option: 'foo'
    #   message.client #=> #<Outbox::Clients::TestClient>
    def client(client = nil, options = nil)
      if client.nil?
        @client
      else
        @client = self.class.send(:get_client, client, options)
      end
    end
  end
end
