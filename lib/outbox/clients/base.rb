module Outbox
  module Clients
    class Base
      attr_reader :settings

      # Sets default settings for the client.
      #
      #   MailClient.defaults delivery_method: :sendmail
      #   client = MailClient.new
      #   client.settings[:delivery_method] #=> :sendmail
      def self.defaults(defaults = nil)
        @defaults ||= {}

        if defaults.nil?
          @defaults
        else
          @defaults.merge!(defaults)
        end
      end

      # Creates a new client instance. Settings can be configured per
      # instance by passing in a hash.
      #
      #    client = MailClient.new delivery_method: :sendmail
      #    client.settings[:delivery_method] #=> :sendmail
      def initialize(settings = nil)
        @settings = self.class.defaults.dup
        @settings.merge! settings if settings
      end

      # Delivers the given message.
      #
      # Subclasses must provide an implementation of this method.
      def deliver(message)
        raise NotImplementedError, 'Subclasses must implement a deliver method'
      end
    end
  end
end
