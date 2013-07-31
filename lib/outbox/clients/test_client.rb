module Outbox
  module Clients
    # The TestClient is a bare bones client that does nothing. It is useful
    # when you are testing.
    #
    # It also provides a template of the minimum methods required to make
    # a custom client.
    class TestClient < Base
      # Provides a store of all the message sent with the TestClient so you
      # can check them.
      def self.deliveries
        @@deliveries ||= []
      end

      def deliver(message)
        self.class.deliveries << message
      end
    end
  end
end
