module Outbox
  require 'outbox/errors'
  require 'outbox/version'

  autoload 'MessageClients', 'outbox/message_clients'
  autoload 'MessageFields', 'outbox/message_fields'

  module Clients
    autoload 'TestClient', 'outbox/clients/test_client'
  end

  module Messages
    autoload 'Base', 'outbox/messages/base'
  end
end
